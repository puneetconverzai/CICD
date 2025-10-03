using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Diagnostics.HealthChecks;

namespace CicdPocApp.Controllers;

[ApiController]
[Route("api/[controller]")]
public class HealthController : ControllerBase
{
    private readonly HealthCheckService _healthCheckService;
    private readonly ILogger<HealthController> _logger;

    public HealthController(HealthCheckService healthCheckService, ILogger<HealthController> logger)
    {
        _healthCheckService = healthCheckService;
        _logger = logger;
    }

    [HttpGet]
    public async Task<IActionResult> Get()
    {
        _logger.LogInformation("Health check requested");

        var healthStatus = await _healthCheckService.CheckHealthAsync();
        var response = new
        {
            Status = healthStatus.Status.ToString(),
            TotalDuration = healthStatus.TotalDuration,
            Entries = healthStatus.Entries.Select(entry => new
            {
                Name = entry.Key,
                Status = entry.Value.Status.ToString(),
                Duration = entry.Value.Duration,
                Description = entry.Value.Description,
                Data = entry.Value.Data
            })
        };

        return healthStatus.Status == HealthStatus.Healthy ? Ok(response) : StatusCode(503, response);
    }
}
