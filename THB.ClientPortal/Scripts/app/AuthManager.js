function AuthManager() {
    var self = this;
    var tokenKey = "accessToken";


    self.getToken = function () {
        return localStorage.getItem(tokenKey);
    }

    self.clearToken = function () {
        localStorage.removeItem(tokenKey);
    }
}

var authManager = new AuthManager();