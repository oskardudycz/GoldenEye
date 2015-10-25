using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Backend.Core.Service;
using Shared.Business.DTOs;
using AutoMapper;
using AutoMapper.QueryableExtensions;
using System.Threading.Tasks;
using Shared.Business.Contracts;

namespace Backend.Business.Services
{
    public class TaskRestService: RestServiceBase<TaskDTO>, ITaskRestService
    {
        private readonly ITaskService _service;

        public TaskRestService(ITaskService service)
        {
            _service = service;
        }
        public override void Dispose()
        {
          _service.Dispose();
        }
        public override IQueryable<TaskDTO> Get()
        {

            return _service.GetAll().ProjectTo<TaskDTO>(); 
        }

        public override Task<TaskDTO> Get(int id)
        {

            return Task.Run(() => Mapper.Map<TaskContract, TaskDTO>(_service.GetById(id)));

        }

        public override Task<TaskDTO> Put(TaskDTO dto)
        {
            return Task.Run(() =>
                Mapper.Map<TaskContract, TaskDTO>(
                    _service.Add(Mapper.Map<TaskDTO, TaskContract>(dto))));
        }

        public override Task<TaskDTO> Post(TaskDTO dto)
        {
            return Task.Run(() =>
                Mapper.Map<TaskContract, TaskDTO>(
                    _service.Update(Mapper.Map<TaskDTO, TaskContract>(dto))));
        }

        public override Task<bool> Delete(int id)
        {
            return Task.Run(() => _service.Remove(id));
        }
    }
}
