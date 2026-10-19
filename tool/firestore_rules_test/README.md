Checks firestore.rules on a local Firestore emulator (needs Java and Node).

    cd tool/firestore_rules_test
    npm install firebase-tools @firebase/rules-unit-testing firebase
    npx firebase emulators:exec --only firestore --project demo-flashpedz "node test.mjs"
