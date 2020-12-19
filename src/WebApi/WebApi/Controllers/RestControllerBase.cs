using System.Threading.Tasks;
using GoldenEye.Services;
using Microsoft.AspNetCore.Mvc;

namespace GoldenEye.WebApi.Controllers
{
    public abstract class RestControllerBase<TService, TDto>: ReadonlyControllerBase<TService, TDto>
        where TDto : class
        where TService : ICRUDService<TDto>
    {
        protected RestControllerBase(TService service): base(service)
        {
        }

        protected RestControllerBase()
        {
        }

        public virtual async Task<IActionResult> Put([FromRoute] object id, TDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var result = await Service.Update(id, dto);

            return Ok(result);
        }

        public virtual async Task<IActionResult> Post(TDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var result = await Service.Add(dto);

            return Ok(result);
        }

        public async Task<IActionResult> Delete(object id)
        {
            await Service.Delete(id);

            return NoContent();
        }
    }
}
