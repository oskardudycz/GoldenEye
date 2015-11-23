function TasksService() {

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
                toastr.success('Dodano zlecenie.', 'Sukces');
                app.current("TaskList-nc");
            },
            error: function (data) {
                toastr.error('Wprowadzono nieprawidłowe wartości.', 'Błąd');
            }
        });
    }

    self.getTask = function (id, callback) {
            $.ajax({
                url: 'https://localhost:44300/api/task/' + id,
                dataType: "json",
                type: "GET",
                data: { get_param: 'value' },
                headers: {
                    'Authorization': "Bearer " + authManager.getToken()
                },
                success: function (data) {
                    callback(data);
                }
            });
    };

    self.getTaskTypes = function (list) {
        $.ajax({
            url: 'https://localhost:44300/api/tasktype/',
            dataType: "json",
            type: "GET",
            data: { get_param: 'value' },
            headers: {
                'Authorization': "Bearer " + authManager.getToken()
            },
            success: function (data) {
                list.push(data);
            }
        });
    }
}

var service = new TasksService();