function UserService() {

    var self = this;

    function handleStandardError(jqXHR, exception) {
        if (jqXHR.status === 401) {
            handleLogOut();
            return true;
        }
        return false;
    }

    self.getUser = function (cached, callback) {
        $.ajax({
            url: '/api/user/1',
            dataType: "json",
            contentType: 'application/json; charset=utf-8',
            type: "GET",
            data: { get_param: 'value' },
            headers: {
                'Authorization': "Bearer " + authManager.getToken()
            }
        }).done(function (data) {
            callback(cached, data);
        });
    }
}

var userService = new UserService();