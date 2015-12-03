function UserDataProvider() {
    var self = this;

    var userDataKey = "UserData";

    var userName = undefined;

    var notifier = ko.observable();

    self.Get = function () {
        notifier();

        if (authManager.isLogged()) {
            notifier();
        }

        var cached = cache.Get(userDataKey);

        if (cached) {
            return cached;
        }

        userService.getUser(cached);

        //cached = { FirstName: "Jan", LastName: "Kowalski", Email: userName }
        cache.Set(cached);

        notifier();

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