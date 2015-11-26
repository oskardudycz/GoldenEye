function UserDataProvider() {
    var self = this;

    var userDataKey = "UserData";

    var userName = undefined;

    var notifier = ko.observable();
    

    self.Get = function () {
        notifier();
        var cached = cache.Get(userDataKey);

        if (cached) {
            return cached;
        }

        $.ajax({
                url: 'https://localhost:44300/api/modeleruser/1',
                dataType: "json",
                contentType: 'application/json; charset=utf-8',
                type: "GET",
                data: { get_param: 'value' },
                headers: {
                    'Authorization': "Bearer " + authManager.getToken()
                },
                success: function (data) {
                    var user = ko.mapping.fromJS(data);
                    cached = { FirstName: user.FirstName, LastName: user.LastName, Email: user.userName }
                }
            });

        //cached = { FirstName: "Jan", LastName: "Kowalski", Email: userName }
        cache.Set(cached);

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