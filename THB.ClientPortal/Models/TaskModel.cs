using Shared.Core.DTOs;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;
using Shared.Core;

namespace Frontend.Web.Models
{
    public class TaskModel: DTOBase
    {
        public int Id { get; set; }
        [Required]
        public string TaskName { get; set; }
        [Required]
        public int Number { get; set; }
        public DateTime Date { get; set; }
        public string Type { get; set; }
        public bool IsInternal { get; set; }
        public int Amount { get; set; }
        public TimeSpan Time { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        [Required]
        public DateTime PlanDate { get; set; }
        public string Description { get; set; }
        public string Color { get; set; }
        public float DonePercentage { get; set; }
    }
}