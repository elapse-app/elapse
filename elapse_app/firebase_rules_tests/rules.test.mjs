import { after, before, beforeEach, test } from 'node:test';
import { readFileSync } from 'node:fs';

import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  collection,
  doc,
  getDoc,
  getDocs,
  query,
  serverTimestamp,
  setDoc,
  updateDoc,
  where,
} from 'firebase/firestore';
import { getBytes, ref, uploadBytes } from 'firebase/storage';

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
