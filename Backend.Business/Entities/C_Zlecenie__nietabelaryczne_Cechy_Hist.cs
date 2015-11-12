namespace Backend.Business.Context
{
    using System;
    using System.ComponentModel.DataAnnotations.Schema;

    public class C_Zlecenie__nietabelaryczne_Cechy_Hist
    {
        public int Id { get; set; }

        public int? IdArch { get; set; }

        public int? IdArchLink { get; set; }

        public int ObiektId { get; set; }

        public int CechaId { get; set; }

        public short? CalculatedByAlrithm { get; set; }

        public short? VirtualTypeId { get; set; }

        public bool? IsValidForAlrithm { get; set; }

        public int? AlrithmRun { get; set; }

        [Column(TypeName = "xml")]
        public string ColumnsSet { get; set; }

        public int? ValInt { get; set; }

        public string ValString { get; set; }

        public double? ValFloat { get; set; }

        public bool? ValBit { get; set; }

        public decimal? ValDecimal { get; set; }

        public DateTime? ValDatetime { get; set; }

        public int? ValDictionary { get; set; }

        [Column(TypeName = "date")]
        public DateTime? ValDate { get; set; }

        public TimeSpan? ValTime { get; set; }

        [Column(TypeName = "xml")]
        public string ValXml { get; set; }

        [Column(TypeName = "xml")]
        public string ValRef { get; set; }

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

        public short Priority { get; set; }

        public short? UIOrder { get; set; }

        public DateTime RealCreatedOn { get; set; }

        public DateTime? RealLastModifiedOn { get; set; }

        public DateTime? RealDeletedFrom { get; set; }
    }
}
