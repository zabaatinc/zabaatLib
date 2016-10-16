import QtQuick 2.5
pragma Singleton
QtObject {
    readonly property int notloggedIn         : 0;
    readonly property int loggedIn            : 1;
    readonly property int skippedLogin        : 2;
    readonly property int attemptingLogin     : 3;
    readonly property int attemptingLogout    : 4;
    readonly property int attemptingSkipLogin : 5;
}
