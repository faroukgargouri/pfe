
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TrikiApi.Data;
using TrikiApi.Models;

namespace TrikiApi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class VisiteController : ControllerBase
    {
        private readonly TrikiDbContext _context;

        public VisiteController(TrikiDbContext context)
        {
            _context = context;
        }

        [HttpPost]
        public async Task<IActionResult> PostVisite([FromBody] Visite visite)
        {
            _context.Visites.Add(visite);
            await _context.SaveChangesAsync();
            return Ok(visite);
        }

        // 🔁 Endpoint pour récupérer les visites par utilisateur
        [HttpGet("user/{userId}")]
        public async Task<IActionResult> GetVisitesByUser(int userId)
        {
            var visites = await _context.Visites
                .Where(v => v.UserId == userId)
                .ToListAsync();

            return Ok(visites);
        }
// PUT: api/visite/{id}
[HttpPut("{id}")]
public async Task<IActionResult> PutVisite(int id, [FromBody] Visite visite)
{
    if (id != visite.Id)
        return BadRequest(new { message = "ID incohérent" });

    var existing = await _context.Visites.FindAsync(id);
    if (existing == null) return NotFound(new { message = "Visite non trouvée" });

    existing.CodeVisite = visite.CodeVisite;
    existing.DateVisite = visite.DateVisite;
    existing.CodeClient = visite.CodeClient;
    existing.RaisonSociale = visite.RaisonSociale;
    existing.CompteRendu = visite.CompteRendu;

    await _context.SaveChangesAsync();
    return Ok(existing);
}

// DELETE: api/visite/{id}
[HttpDelete("{id}")]
public async Task<IActionResult> DeleteVisite(int id)
{
    var visite = await _context.Visites.FindAsync(id);
    if (visite == null) return NotFound(new { message = "Visite introuvable" });

    _context.Visites.Remove(visite);
    await _context.SaveChangesAsync();
    return Ok(new { message = "Supprimée" });
}


    }
}
