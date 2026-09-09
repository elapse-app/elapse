import { after, before, beforeEach, test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';

import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  collection,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  query,
  serverTimestamp,
  setDoc,
  updateDoc,
  where,
  writeBatch,
} from 'firebase/firestore';
import { deleteObject, getBytes, ref, uploadBytes } from 'firebase/storage';

const projectId = 'demo-elapse';
const bucket = `gs://${projectId}.appspot.com`;
let testEnvironment;

before(async () => {
  testEnvironment = await initializeTestEnvironment({
    projectId,
    firestore: {
      rules: readFileSync(new URL('../firestore.rules', import.meta.url), 'utf8'),
    },
    storage: {
      rules: readFileSync(new URL('../storage.rules', import.meta.url), 'utf8'),
    },
  });
});

beforeEach(async () => {
  await Promise.all([
    testEnvironment.clearFirestore(),
    testEnvironment.clearStorage(),
  ]);
});

after(async () => {
  await testEnvironment.cleanup();
});

async function seedGroup({ allowJoin = false } = {}) {
  await testEnvironment.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), 'teamGroups', 'group-1'), {
      adminId: 'alice',
      groupName: 'Test team',
      joinCode: 'AB12-CD34',
      allowJoin,
      members: { alice: 'Alice Admin' },
    });
  });
}

test('private groups are readable only by members', async () => {
  await seedGroup();
  const alice = testEnvironment.authenticatedContext('alice').firestore();
  const bob = testEnvironment.authenticatedContext('bob').firestore();

  await assertSucceeds(getDoc(doc(alice, 'teamGroups', 'group-1')));
  await assertFails(getDoc(doc(bob, 'teamGroups', 'group-1')));
});

test('join-code queries must explicitly select joinable groups', async () => {
  await seedGroup({ allowJoin: true });
  const bob = testEnvironment.authenticatedContext('bob').firestore();
  const groups = collection(bob, 'teamGroups');

  await assertSucceeds(
    getDocs(
      query(
        groups,
        where('joinCode', '==', 'AB12-CD34'),
        where('allowJoin', '==', true),
      ),
    ),
  );
  await assertFails(
    getDocs(query(groups, where('joinCode', '==', 'AB12-CD34'))),
  );
});

test('a user can join as themselves but cannot add another member', async () => {
  await seedGroup({ allowJoin: true });
  const bob = testEnvironment.authenticatedContext('bob').firestore();
  const group = doc(bob, 'teamGroups', 'group-1');

  await assertSucceeds(
    updateDoc(group, {
      'members.bob': 'Bob Scout',
      updatedAt: serverTimestamp(),
    }),
  );
  await assertFails(updateDoc(group, { 'members.mallory': 'Mallory' }));
});

test('members can create scout sheets while outsiders cannot read them', async () => {
  await seedGroup();
  const alice = testEnvironment.authenticatedContext('alice').firestore();
  const bob = testEnvironment.authenticatedContext('bob').firestore();
  const sheetPath = ['teamGroups', 'group-1', 'scoutsheets', 'sheet-1'];
  const sheet = {
    teamID: '1234A',
    tournamentID: '42',
    createTime: serverTimestamp(),
    latestUpdate: serverTimestamp(),
    schemaVersion: 2,
    template: { id: 'template', name: 'Pit scout', fields: [] },
    answers: {},
    photos: [],
    isEditing: true,
    allowJoin: false,
  };

  await assertSucceeds(setDoc(doc(alice, ...sheetPath), sheet));
  await assertSucceeds(getDoc(doc(alice, ...sheetPath)));
  await assertFails(getDoc(doc(bob, ...sheetPath)));
});

test('only an admin can change group settings', async () => {
  await seedGroup();
  await testEnvironment.withSecurityRulesDisabled(async (context) => {
    await updateDoc(doc(context.firestore(), 'teamGroups', 'group-1'), {
      'members.bob': 'Bob Scout',
    });
  });
  const alice = testEnvironment.authenticatedContext('alice').firestore();
  const bob = testEnvironment.authenticatedContext('bob').firestore();

  await assertSucceeds(
    updateDoc(doc(alice, 'teamGroups', 'group-1'), {
      groupName: 'Renamed team',
    }),
  );
  await assertFails(
    updateDoc(doc(bob, 'teamGroups', 'group-1'), {
      groupName: 'Hijacked team',
    }),
  );
});

test('user profiles are private to their authenticated owner', async () => {
  await testEnvironment.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), 'users', 'alice'), {
      email: 'alice@example.com',
      firstName: 'Alice',
      lastName: 'Admin',
      team: {},
      groupId: [],
      verified: false,
    });
  });
  const alice = testEnvironment.authenticatedContext('alice').firestore();
  const bob = testEnvironment.authenticatedContext('bob').firestore();

  await assertSucceeds(getDoc(doc(alice, 'users', 'alice')));
  await assertFails(getDoc(doc(bob, 'users', 'alice')));
});

test('Storage accepts only small team-member image uploads', async () => {
  await seedGroup();
  const alice = testEnvironment.authenticatedContext('alice').storage(bucket);
  const bob = testEnvironment.authenticatedContext('bob').storage(bucket);
  const path =
    'teamGroups/group-1/scoutsheets/images/alice/photo.png';
  const image = new Uint8Array([137, 80, 78, 71]);

  await assertSucceeds(
    uploadBytes(ref(alice, path), image, { contentType: 'image/png' }),
  );
  await assertSucceeds(getBytes(ref(alice, path)));
  await assertFails(
    uploadBytes(
      ref(bob, 'teamGroups/group-1/scoutsheets/images/bob/photo.png'),
      image,
      { contentType: 'image/png' },
    ),
  );
  await assertFails(
    uploadBytes(
      ref(alice, 'teamGroups/group-1/scoutsheets/images/alice/not-image.txt'),
      image,
      { contentType: 'text/plain' },
    ),
  );
  await assertFails(
    uploadBytes(
      ref(alice, 'teamGroups/group-1/scoutsheets/images/alice/oversize.png'),
      new Uint8Array(5 * 1024 * 1024 + 1),
      { contentType: 'image/png' },
    ),
  );
});

test('group lifecycle: create, join, save, reload, delete photo, leave and revoke access', async () => {
  const alice = testEnvironment.authenticatedContext('alice', { email: 'alice@example.com' });
  const bob = testEnvironment.authenticatedContext('bob', { email: 'bob@example.com' });
  for (const [context, uid] of [[alice, 'alice'], [bob, 'bob']]) {
    await assertSucceeds(setDoc(doc(context.firestore(), 'users', uid), {
      email: `${uid}@example.com`, firstName: uid, lastName: 'Tester',
      team: {}, groupId: [], verified: false,
    }));
  }
  const db = alice.firestore();
  const group = doc(db, 'teamGroups', 'lifecycle');
  const create = writeBatch(db);
  create.set(group, {
    adminId: 'alice', groupName: 'Lifecycle', joinCode: 'TEST-1234',
    allowJoin: true, members: { alice: 'Alice' },
  });
  create.update(doc(db, 'users', 'alice'), { groupId: ['lifecycle'] });
  await assertSucceeds(create.commit());
  const bobDb = bob.firestore();
  const join = writeBatch(bobDb);
  join.update(doc(bobDb, 'teamGroups', 'lifecycle'), { 'members.bob': 'Bob' });
  join.update(doc(bobDb, 'users', 'bob'), { groupId: ['lifecycle'] });
  await assertSucceeds(join.commit());

  const sheetPath = ['teamGroups', 'lifecycle', 'scoutsheets', 'robot'];
  await assertSucceeds(setDoc(doc(db, ...sheetPath), {
    teamID: '10K', tournamentID: '64244', createTime: serverTimestamp(),
    latestUpdate: serverTimestamp(), schemaVersion: 2,
    template: { id: 'custom', name: 'Custom', fields: [{ id: 'notes', type: 'longText', label: 'Notes' }] },
    answers: {}, photos: [], isEditing: true,
  }));
  await assertSucceeds(updateDoc(doc(bobDb, ...sheetPath), {
    answers: { notes: 'Saved by teammate', score: 0, ready: false }, isEditing: false,
  }));
  assert.deepEqual((await getDoc(doc(db, ...sheetPath))).data().answers,
    { notes: 'Saved by teammate', score: 0, ready: false });
  await assertFails(updateDoc(doc(bobDb, ...sheetPath), { template: { id: 'replacement' } }));

  const photoPath = 'teamGroups/lifecycle/scoutsheets/images/bob/robot.png';
  const bobPhoto = ref(bob.storage(bucket), photoPath);
  await assertSucceeds(uploadBytes(bobPhoto, new Uint8Array([137, 80, 78, 71]), { contentType: 'image/png' }));
  await assertSucceeds(updateDoc(doc(bobDb, ...sheetPath), { photos: [photoPath] }));
  assert.deepEqual((await getDoc(doc(db, ...sheetPath))).data().photos, [photoPath]);
  await assertSucceeds(deleteObject(ref(alice.storage(bucket), photoPath)));
  await assertSucceeds(updateDoc(doc(db, ...sheetPath), { photos: [] }));
  assert.deepEqual((await getDoc(doc(bobDb, ...sheetPath))).data().photos, []);

  const leave = writeBatch(db);
  leave.update(group, { members: { bob: 'Bob' }, adminId: 'bob', allowJoin: false });
  leave.update(doc(db, 'users', 'alice'), { groupId: [] });
  await assertSucceeds(leave.commit());
  await assertFails(getDoc(doc(db, ...sheetPath)));
  await assertSucceeds(getDoc(doc(bobDb, ...sheetPath)));
  await assertSucceeds(deleteDoc(doc(bobDb, ...sheetPath)));
  const finish = writeBatch(bobDb);
  finish.delete(doc(bobDb, 'teamGroups', 'lifecycle'));
  finish.update(doc(bobDb, 'users', 'bob'), { groupId: [] });
  await assertSucceeds(finish.commit());
});

test('security regression: joinable groups cannot be enumerated without a code', async () => {
  await seedGroup({ allowJoin: true });
  const outsider = testEnvironment.authenticatedContext('outsider').firestore();
  await assertFails(getDocs(query(collection(outsider, 'teamGroups'), where('allowJoin', '==', true))));
});

test('security regression: an admin cannot erase unrelated memberships', async () => {
  await seedGroup();
  await testEnvironment.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), 'users', 'bob'), { groupId: ['group-1', 'unrelated-group'] });
  });
  const alice = testEnvironment.authenticatedContext('alice').firestore();
  await assertFails(updateDoc(doc(alice, 'users', 'bob'), { groupId: [] }));
});
