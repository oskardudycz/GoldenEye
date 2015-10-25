using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Backend.Core.Service;
using Shared.Business.DTOs;
using Shared.Business.Contracts;

namespace Backend.Business.Services
{
    public interface ITaskService: IBaseService<TaskContract>
    {
    }
}
