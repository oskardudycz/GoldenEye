function TasksService() {

    var self = this;

    function handleLogOut() {
        toastr.error("Zostałeś wylogowany!", "Błąd");
        routing.refresh();
    }

    function handleStandardError(jqXHR, exception) {
        if (jqXHR.status === 401) {
            handleLogOut();
            return true;
        }
        return false;
    }

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
                //toastr.success('Dodano zlecenie.', 'Sukces');
               // app.current("TaskList-nc");
            },
            error: function (jqXHR, exception) {
                if(!handleStandardError(jqXHR, exception))
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
                },
                error: handleStandardError
            });
    };

    self.getTaskTypes = function (list) {
        $.ajax({
            url: 'https://localhost:44300/api/tasktype',
            dataType: "json",
            type: "GET",
            data: { get_param: 'value' },
            headers: {
                'Authorization': "Bearer " + authManager.getToken()
            },
            success: function (data) {
                var taskTypes = ko.mapping.fromJS(data);
                list(taskTypes());
            },
            error: handleStandardError
        });
    }

    self.getClients = function (list) {
        $.ajax({
            url: 'https://localhost:44300/api/Customer',
            dataType: "json",
            type: "GET",
            data: { get_param: 'value' },
            headers: {
                'Authorization': "Bearer " + authManager.getToken()
            },
            success: function (data) {
                var clients = ko.mapping.fromJS(data);
                list(clients());
            },
            error: handleStandardError
        });
    }
}

var service = new TasksService();