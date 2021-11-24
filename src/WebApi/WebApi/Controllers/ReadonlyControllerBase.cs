using System.Linq;
using System.Threading.Tasks;
using GoldenEye.Services;
using Microsoft.AspNetCore.Mvc;

namespace GoldenEye.WebApi.Controllers;

public abstract class ReadonlyControllerBase<TService, TDto>: ControllerBase
    where TService : IReadonlyService<TDto> where TDto : class
{
    protected TService Service;

    protected ReadonlyControllerBase(TService service)
    {
        Service = service;
    }

    protected ReadonlyControllerBase()
    {
    }

    public virtual IQueryable<TDto> Get()
    {
        return Service.Query();
    }

    public virtual async Task<IActionResult> Get(object id)
    {
        var dto = await Service.Get(id);
        if (dto == null) return NotFound();

        return Ok(dto);
    }
}
