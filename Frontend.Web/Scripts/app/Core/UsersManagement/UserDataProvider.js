function UserDataProvider() {
    var self = this;

    var userDataKey = "UserData";

    var userName = undefined;

    var notifier = ko.observable();

    function UpdateUser(data) {
        cache.Set(userDataKey, data);
        notifier.valueHasMutated();
    }

    self.Get = function () {
        notifier();

        if (authManager.isLogged()) {
            notifier.valueHasMutated();
        }

        var cached = cache.Get(userDataKey);

        if (cached) {
            return cached;
        }

        userService.getUser("SampleAdmina", UpdateUser);

        return cached;
    }

    self.Set = function (email) {
        userName = email;
        self.Clear();
    }

    self.Clear = function () {
        cache.Clear(userDataKey);
        notifier.valueHasMutated();
    }
}

var userData = new UserDataProvider();