enum DashboardTemplates {
  barcodes, crops, minMaxTable, sampleTests
}

extension Presentation on DashboardTemplates {
  String toPresentation() {
    switch (this) {
      case DashboardTemplates.barcodes:
        return "Barcodes template";
      case DashboardTemplates.crops:
        return "Crops template";
      case DashboardTemplates.minMaxTable:
        return "Min Max Table template";
      case DashboardTemplates.sampleTests:
        return "Sample Tests template";
    }
  }

  String getDownloadPath() {
    String prefix = "templates/";
    switch (this) {
      case DashboardTemplates.barcodes:
        return "${prefix}barcodes_template.xlsx";
      case DashboardTemplates.crops:
        return "${prefix}crops_template.xlsx";
      case DashboardTemplates.minMaxTable:
        return "${prefix}min_max_table_template.xlsx";
      case DashboardTemplates.sampleTests:
        return "${prefix}sample_tests_template.xlsx";
    }
  }
}