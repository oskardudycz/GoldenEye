using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Backend.Core.Service;
using Shared.Business.DTOs;
using Backend.Business.Entities;
using Shared.Business.Contracts;
using AutoMapper;
using AutoMapper.QueryableExtensions;
using Backend.Business.Repository;

namespace Backend.Business.Services
{
    public class TaskService: BaseService<TaskEntity, TaskContract>, ITaskService
    {
        private readonly ITaskRepository _repository;
        public TaskService(ITaskRepository repository): base(repository)
        {
            _repository = repository;
        }
    }
}