function RestService() {

    var self = this;
    var token = sessionStorage.getItem('accessToken');

    self.loadList = function (list) {
        $.ajax("https://localhost:44300/api/Task", {
            dataType: "json",
            type: "GET",
            data: { get_param: 'value' },
            headers: {
                'Authorization': "Bearer " + token
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
            headers: {
                'Authorization': "Bearer " + token
            },
            success: function (data) {
                app.current("tasks-list");
            }
        });
    }

    self.getTask = function (id) {
            $.ajax({
                url: 'https://localhost:44300/api/task/' + id,
                type: "GET",
                data: { get_param: 'value' },
                headers: {
                    'Authorization': "Bearer " + token
                },
                dataType: "json",
                success: function (data) {
                    
                }
            });
        };
}

var service = new RestService();