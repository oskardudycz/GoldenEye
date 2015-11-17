namespace Backend.Business.Context
{
    using System.ComponentModel.DataAnnotations.Schema;

    public class Task
    {
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        public int Id { get; set; }

        public string TaskName { get; set; }

        public string Customer { get; set; }

        public string CustomerColor { get; set; }

        public string Date { get; set; }

        public string Type { get; set; }

        public string IsInternal { get; set; }

        public string Amount { get; set; }

        public string PlannedTime { get; set; }

        public string PlannedStartDate { get; set; }

        public string PlannedEndDate { get; set; }

        public string Color { get; set; }

        public string PlanningDate { get; set; }

        public string Description { get; set; }
    }
}
