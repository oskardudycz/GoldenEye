using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Backend.Core.Repository;
using Backend.Business.Entities;
using Backend.Core.Context;
using System.Data.Entity;
using Backend.Business.Context;

namespace Backend.Business.Repository
{
    public class TaskRepository: BaseRepository<TaskEntity>, ITaskRepository
    {
        private readonly ITHBContext _taskContext;

        public TaskRepository(ITHBContext context): base(context, context.Tasks)
        {
            _taskContext = context;
        }
    }
}