function UserService() {

    var self = this;

    function handleStandardError(jqXHR, exception) {
        if (jqXHR.status === 401) {
            handleLogOut();
            return true;
        }
        return false;
    }

    self.getUser = function (cached) {
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
            cached = { FirstName: data.FirstName, LastName: data.LastName, Email: data.UserName }
        });
    }
}

var userService = new UserService();