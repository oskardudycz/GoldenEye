function AuthManager() {
    var self = this;
    var tokenKey = "accessToken";

    var notifier = ko.observable();

    this.getToken = function () {
        notifier();
        return cache.Get(tokenKey);
    }

    this.clearToken = function () {
        cache.Clear(tokenKey);
        notifier.valueHasMutated();
    }

    this.setToken = function (token) {
        cache.Set(tokenKey, token);
        notifier.valueHasMutated();
    };

    this.isLogged = function () {
        return self.getToken() != undefined;
    }
}

var authManager = new AuthManager();