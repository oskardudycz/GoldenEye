namespace Backend.Business.Context
{
    using System;
    using System.Collections.Generic;
    using System.ComponentModel.DataAnnotations;
    using System.ComponentModel.DataAnnotations.Schema;

    [Table("_Zlecenie  nietabelaryczne")]
    public class C_Zlecenie__nietabelaryczne
    {
        public C_Zlecenie__nietabelaryczne()
        {
            C_Zlecenie__nietabelaryczne1 = new HashSet<C_Zlecenie__nietabelaryczne>();
            C_Zlecenie__nietabelaryczne11 = new HashSet<C_Zlecenie__nietabelaryczne>();
        }

        public int Id { get; set; }

        public int? IdArch { get; set; }

        public int? IdArchLink { get; set; }

        [Required]
        [StringLength(256)]
        public string Nazwa { get; set; }

        public bool? IsAlternativeHistory { get; set; }

        public bool? IsMainHistFlow { get; set; }

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

        public bool IsValid { get; set; }

        public DateTime ValidFrom { get; set; }

        public DateTime? ValidTo { get; set; }

        public bool IsDeleted { get; set; }

        public DateTime? DeletedFrom { get; set; }

        public int? DeletedBy { get; set; }

        public DateTime CreatedOn { get; set; }

        public int? CreatedBy { get; set; }

        public DateTime? LastModifiedOn { get; set; }

        public int? LastModifiedBy { get; set; }

        public DateTime RealCreatedOn { get; set; }

        public DateTime? RealLastModifiedOn { get; set; }

        public DateTime? RealDeletedFrom { get; set; }

        public virtual ICollection<C_Zlecenie__nietabelaryczne> C_Zlecenie__nietabelaryczne1 { get; set; }

        public virtual C_Zlecenie__nietabelaryczne C_Zlecenie__nietabelaryczne2 { get; set; }

        public virtual ICollection<C_Zlecenie__nietabelaryczne> C_Zlecenie__nietabelaryczne11 { get; set; }

        public virtual C_Zlecenie__nietabelaryczne C_Zlecenie__nietabelaryczne3 { get; set; }
    }
}
