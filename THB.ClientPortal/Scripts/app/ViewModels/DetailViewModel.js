function DetailViewModel(id) {
    var self = this;
    self.Id = ko.observable(id);
    self.Details = ko.observableArray();

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
    self.Progress = ko.observable();

    self.getTask = function () {
        service.getTask(id, self.Details);
    };

    self.viewModelName = "Detale";
    self.viewName = "Detale";

}

ko.components.register("task-details", {
    viewModel: {
        createViewModel: function (params, componentInfo) {
            var viewModel = new DetailViewModel(params);

            viewModel.getTask(viewModel.Id());

            return viewModel;
        }
    },
    template: { element: "Detale" }
});