function LoginViewModel() {
    var self = this;
    
    self.result = ko.observable();
    self.user = ko.observable();
    self.loggedIn = ko.computed(authManager.isLogged);

    self.loggedInUserFirstName = ko.computed(function () {
        var user = userData.Get();

        if (user == undefined)
            return undefined;

        return user.FirstName;
    });

    self.registerEmail = ko.observable().extend({
        email: true,
        required: true
    });
    self.registerPassword = ko.observable().extend({
        minLength: 6,
        maxLength: 30,
        required: true
    });
    self.registerPassword2 = ko.observable().extend({
        equal: self.registerPassword,
        required: true
    });
    self.firstName = ko.observable().extend({
        required: true,
        minLength: 3,
        maxLength: 15
    });
    self.lastName = ko.observable().extend({
        required: true,
        minLength: 3,
        maxLength: 15
    });

    self.loginEmail = ko.observable().extend({
        //email: true,
        required: true
    });
    self.loginPassword = ko.observable();

    function showError(jqXHR) {
        self.result(jqXHR.status + ': ' + jqXHR.statusText);
    }

    self.register = function () {
        self.result('');

        var data = {
            Email: self.registerEmail(),
            Password: self.registerPassword(),
            ConfirmPassword: self.registerPassword2(),
            FirstName: self.firstName(),
            LastName: self.lastName()
        };

       // loginService.register();

        $.ajax({
            type: "POST",
            url: $("base").attr("href") + "api/Account/Register",
            contentType: 'application/json; charset=utf-8',
            data: JSON.stringify(data)
        }).done(function (data) {
            self.result("Done!");
            toastr.success('Możesz się teraz zalogować.', 'Rejestracja przebiegła pomyślnie');
        }).fail(function (jqXHR, exception) {
            toastr.error('Nieprawidłowe hasło.', 'Błąd');
        });
    }

    self.login = function () {
        self.result("");

        var loginData = {
            grant_type: "password",
            username: self.loginEmail(),
            password: self.loginPassword()
        };

       // loginService.login();

        $.ajax({
            type: "POST",
            url: $("base").attr("href") + "Token",
            data: loginData
        }).done(function (data) {
            self.user(data.userName);
            userData.Set(data.userName);
            // Cache the access token in session storage.
            authManager.setToken(data.access_token);
            app.current("TaskList-nc");
        }).fail(function () {
            toastr.error('Błędny login lub hasło.', 'Błąd');
        });
    }

    self.logout = function () {
        self.user("");
        authManager.clearToken();
        userData.Clear();
        app.current("Login-nc");
    }
}