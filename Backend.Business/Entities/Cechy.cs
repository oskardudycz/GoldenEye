namespace Backend.Business.Context
{
    using System;
    using System.Collections.Generic;
    using System.ComponentModel.DataAnnotations;
    using System.ComponentModel.DataAnnotations.Schema;
    using System.Data.Entity.Spatial;

    [Table("Cechy")]
    public class Cechy
    {
        public int? TableID { get; set; }

        [Key]
        public int Cecha_ID { get; set; }

        public int? IdArch { get; set; }

        public int? IdArchLink { get; set; }

        public bool? IsValid { get; set; }

        public DateTime ValidFrom { get; set; }

        public DateTime? ValidTo { get; set; }

        [Required]
        [StringLength(50)]
        public string Nazwa { get; set; }

        [StringLength(50)]
        public string NazwaSkrocona { get; set; }

        [StringLength(200)]
        public string Hint { get; set; }

        [StringLength(500)]
        public string Opis { get; set; }

        [StringLength(50)]
        public string WartoscSlownika { get; set; }

        public int TypID { get; set; }

        [StringLength(50)]
        public string Format { get; set; }

        public bool CzyWymagana { get; set; }

        public bool CzyPusta { get; set; }

        public bool CzyWyliczana { get; set; }

        public bool CzyPrzetwarzana { get; set; }

        public bool CzyFiltrowana { get; set; }

        public bool CzyJestDanaOsobowa { get; set; }

        [StringLength(20)]
        public string WartoscDomyslna { get; set; }

        public string ListaWartosciDopuszczalnych { get; set; }

        public bool? CzyCechaUzytkownika { get; set; }

        [StringLength(3)]
        public string StatusA { get; set; }

        [StringLength(3)]
        public string StatusB { get; set; }

        [StringLength(3)]
        public string StatusC { get; set; }

        [StringLength(2)]
        public string Widocznosc { get; set; }

        public bool IsDeleted { get; set; }

        public DateTime? DeletedFrom { get; set; }

        public int? DeletedBy { get; set; }

        public DateTime CreatedOn { get; set; }

        public int? CreatedBy { get; set; }

        public DateTime? LastModifiedOn { get; set; }

        public int? LastModifiedBy { get; set; }

        public bool IsStatus { get; set; }

        public int? StatusS { get; set; }

        public DateTime? StatusSFrom { get; set; }

        public DateTime? StatusSTo { get; set; }

        public int? StatusSFromBy { get; set; }

        public int? StatusSToBy { get; set; }

        public int? StatusW { get; set; }

        public DateTime? StatusWFrom { get; set; }

        public DateTime? StatusWTo { get; set; }

        public int? StatusWFromBy { get; set; }

        public int? StatusWToBy { get; set; }

        public int? StatusP { get; set; }

        public DateTime? StatusPFrom { get; set; }

        public DateTime? StatusPTo { get; set; }

        public int? StatusPFromBy { get; set; }

        public int? StatusPToBy { get; set; }

        public DateTime? ObowiazujeOd { get; set; }

        public DateTime? ObowiazujeDo { get; set; }

        public bool? IsAlternativeHistory { get; set; }

        public bool? IsMainHistFlow { get; set; }

        public int? ControlSize { get; set; }

        public int? JednostkaMiary { get; set; }

        public bool CzySlownik { get; set; }

        public DateTime RealCreatedOn { get; set; }

        public DateTime? RealLastModifiedOn { get; set; }

        public DateTime? RealDeletedFrom { get; set; }

        public int? PrzedzialCzasowyId { get; set; }

        public bool CharakterChwilowy { get; set; }

        public int? RelationTypeId { get; set; }

        public int? UnitTypeId { get; set; }

        public bool IsBlocked { get; set; }

        public bool Sledzona { get; set; }
    }
}
