using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Shared.Core.DTOs;

namespace Shared.Business.DTOs
{
    public class TaskDTO: DTOBase
    {
        public int Id { get; set; }
        public string TaskName { get; set; }
        public int Number { get; set; }
        public DateTime Date { get; set; }
        public string Type { get; set; }
        public bool IsInternal { get; set; }
        public int Amount { get; set; }
        public TimeSpan Time { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public DateTime PlanDate { get; set; }
        public string Description { get; set; }
        public string Color { get; set; }
        public float DonePercentage { get; set; }
    }
}