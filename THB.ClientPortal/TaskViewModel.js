var TaskViewModel = function () {
    var self = this;
    self.tasks = ko.observableArray([]);

    self.TaskName = ko.observable();
    self.Number = ko.observable();
    self.Date = ko.observable();
    self.Type = ko.observable();
    self.IsInternal = ko.observable();
    self.Amount = ko.observable();
    self.Time = ko.observable();
    self.StartDate = ko.observable();
    self.PlanDate = ko.observable();
    self.EndDate = ko.observable();
    self.Description = ko.observable();
    self.Color = ko.observable();

    self.Id = ko.observable();

    self.currentView = ko.observable();
    self.views = ko.observableArray(["Zlecenia", "Dodaj"]);
    
    self.viewModelName = "Dodaj";
    self.viewName = "Dodaj";
};

TaskViewModel.prototype.save = function () {
    var self = this;
    var taskname = self.TaskName();
    var number = self.Number();
    $.ajax("http://localhost:35761/api/task", {
        data: { TaskName: taskname, Number: number },
        type: "PUT",
        success: function (data) { }
    });
};

TaskViewModel.prototype.addTask = function () {
    var self = this;
    self.tasks.push({ TaskName: self.Taskname, Number: self.Number });
    self.save();
};

var loadTasks = function (model) {
    $.getJSON("http://localhost:35761/api/task", function (data) {
        var newTasks = ko.mapping.fromJS(data);
        model.tasks(newTasks());
    });
};