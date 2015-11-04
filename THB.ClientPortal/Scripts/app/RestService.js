function RestService() {

    var self = this;

    self.loadList = function (list) {
        $.ajax("https://localhost:44300/api/Task", {
            dataType: "json",
            type: "GET",
            data: { get_param: "value" },
            headers: {
                'Authorization': "Bearer " + authManager.getToken()
            },
            success: function (data) {
                var tasks = ko.mapping.fromJS(data);
                list(tasks());
            }
        });
    }

    self.addTask = function (model) {
        $.ajax("https://localhost:44300/api/Task", {
            dataType: "json",
            type: "PUT",
            data: ko.toJSON(model),
            contentType: "application/json; charset=utf-8",
            headers: {
                'Authorization': "Bearer " + authManager.getToken()
            },
            success: function (data) {
                app.current("tasks-list");
            }
        });
    }

    self.getTask = function (id, details) {
            $.ajax({
                url: 'https://localhost:44300/api/task/' + id,
                dataType: "json",
                type: "GET",
                data: { get_param: 'value' },
                headers: {
                    'Authorization': "Bearer " + authManager.getToken()
                },
                success: function (data) {
                    var task = ko.mapping.fromJS(data);
                    details(task());
                }
            });
        };
}

var service = new RestService();

function AuthManager() {
    var self = this;
    var tokenKey = "accessToken";


    self.getToken = function (){
        return localStorage.getItem(tokenKey);
    }

    self.clearToken = function() {
        localStorage.removeItem(tokenKey);
    }
}

var authManager = new AuthManager();