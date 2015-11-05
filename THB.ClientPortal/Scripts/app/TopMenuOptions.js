$(document).ready(function () {
    if (authManager.getToken()) {
        $("#notLoggedIn").hide();
        $("#loggedIn").show();
    }
    else if (!authManager.getToken()) {
        $("#loggedIn").hide();
        $("#notLoggedIn").show();
    }
});