function LoginViewModel() {
    var self = this;

    var tokenKey = 'accessToken';

    self.result = ko.observable();
    self.user = ko.observable();

    self.registerEmail = ko.observable().extend({
        email: true,
        required: true
    });
    self.registerPassword = ko.observable().extend({
        minLength: 6,
        maxLength: 15,
        required: true
    });
    self.registerPassword2 = ko.observable().extend({
        equal: self.registerPassword,
        required: true
    });

    self.loginEmail = ko.observable().extend({
        email: true,
        required: true
    });
    self.loginPassword = ko.observable();

    function showError(jqXHR) {
        self.result(jqXHR.status + ': ' + jqXHR.statusText);
    }

    self.callApi = function () {
        self.result('');

        var token = localStorage.getItem(tokenKey);
        var headers = {};
        if (token) {
            headers.Authorization = 'Bearer ' + token;
        }

        $.ajax({
            type: 'GET',
            url: 'https://localhost:44300/api/values',
            headers: headers
        }).done(function (data) {
            self.result(data);
        }).fail(showError);
    }

    self.register = function () {
        self.result('');

        var data = {
            Email: self.registerEmail(),
            Password: self.registerPassword(),
            ConfirmPassword: self.registerPassword2()
        };

        $.ajax({
            type: "POST",
            url: 'https://localhost:44300/api/Account/Register',
            contentType: 'application/json; charset=utf-8',
            data: JSON.stringify(data)
        }).done(function (data) {
            self.result("Done!");
            alert("Rejestracja przebiegła pomyślnie. Możesz się teraz zalogować.")
        }).fail(function () {
            $("#register-error-message").text("Błędne hasło.").fadeIn();
        });
    }

    self.login = function () {
        self.result("");

        var loginData = {
            grant_type: "password",
            username: self.loginEmail(),
            password: self.loginPassword()
        };

        $.ajax({
            type: "POST",
            url: 'https://localhost:44300/Token',
            data: loginData
        }).done(function (data) {
            self.user(data.userName);
            // Cache the access token in session storage.
            localStorage.setItem(tokenKey, data.access_token);
            app.current("tasks-list");
        }).fail(function () {
            $("#login-error-message").text("Błędny login lub hasło.").fadeIn();
        });
    }

    self.logout = function () {
        self.user("");
        localStorage.removeItem(tokenKey);
    }
}
ko.components.register("login-nc", {});
