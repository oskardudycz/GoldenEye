var TaskViewModel = function () {
    this.tasks = ko.observableArray([]);

    this.TaskName = ko.observable();
    this.Number = ko.observable();
    this.Date = ko.observable();
    this.Type = ko.observable();
    this.IsInternal = ko.observable();
    this.Amount = ko.observable();
    this.Time = ko.observable();
    this.StartDate = ko.observable();

    this.Id = undefined;

    this.currentView = ko.observable();
    this.views = ko.observableArray(["Home", "Add", "Edit", "Find"]);
};

TaskViewModel.prototype.save = function () {
    var taskname = this.TaskName();
    $.ajax("http://localhost:1299/api/task", {
        data: { TaskName: taskname },
        type: "PUT",
        success: function (data) { }
    });
};

TaskViewModel.prototype.addTask = function () {
    this.tasks.push({ Id: this.id(), Name: this.name() });
    this.save();
};

var loadTasks = function (model) {
    $.getJSON("http://localhost:1299/api/task", function (data) {
        var newTasks = ko.mapping.fromJS(data);
        model.tasks(newTasks());
    });
};

var vm = new TaskViewModel();
loadTasks(vm);

$(function () {
    ko.applyBindings(vm);
});