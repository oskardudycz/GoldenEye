function DetailViewModel(id) {
    var self = this;
    self.Id = ko.observable(id);

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

    self.getTask = function (id) {
        $.ajax({
            url: 'https://localhost:44300/api/task/' + id,
            type: "GET",
            dataType: "json",
            success: function (data) {
                self.TaskName(data.TaskName);
                self.Number(data.Number);
                self.Date(data.Date);
                self.Type(data.Type);
                self.IsInternal(data.IsInternal);
                self.Amount(data.Amount);
                self.Time(data.Time);
                self.StartDate(data.StartDate);
                self.PlanDate(data.PlanDate);
                self.EndDate(data.EndDate);
                self.Description(data.Description);
                self.Color(data.Color);
                self.Progress(data.Progress);
            }
        });
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