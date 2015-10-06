using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Backend.Core.Repository;
using Backend.Business.Entities;

namespace Backend.Business.Repository
{
    public interface ITaskRepository: IRepository<TaskEntity>
    {
    }
}
