using TrikiApi.Models;

public class Visite
{
    public int Id { get; set; }
    public string CodeVisite { get; set; } = string.Empty;
    public string? DateVisite { get; set; } // 👈 Ajout du ?
    public string CodeClient { get; set; } = string.Empty;
    public string RaisonSociale { get; set; } = string.Empty;
    public string CompteRendu { get; set; } = string.Empty;
    public int UserId { get; set; }
    public User? User { get; set; }
}

