import java.io.*;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.concurrent.*;

// ============================================================================
// 1. CUSTOM EXCEPTION HANDLING (Module 6)
// ============================================================================
class CriticalQualityFaultException extends Exception {
    public CriticalQualityFaultException(String message) {
        super("[CRITICAL QUALITY FAULT] " + message);
    }
}

class BatchHaltException extends Exception {
    public BatchHaltException(String message) {
        super("[BATCH HALTED] " + message);
    }
}

class SensorDataCorruptException extends RuntimeException {
    public SensorDataCorruptException(String message) {
        super("[SENSOR ERROR] " + message);
    }
}

// ============================================================================
// 2. DATA MODELS: CLASSES, OBJECTS & CONSTRUCTORS (Module 4)
// ============================================================================
class Defect {
    private String defectType;
    private double confidenceScore; // e.g., 0.94 (94%)
    private String severity;         // "MINOR", "MAJOR", "CRITICAL"

    public Defect(String defectType, double confidenceScore, String severity) {
        this.defectType = defectType;
        this.confidenceScore = confidenceScore;
        this.severity = severity;
    }

    public String getDefectType() { return defectType; }
    public double getConfidenceScore() { return confidenceScore; }
    public String getSeverity() { return severity; }

    @Override
    public String toString() {
        return String.format("%s (Confidence: %.1f%%, Severity: %s)", 
                defectType, confidenceScore * 100, severity);
    }
}

class InspectionItem {
    private String serialNumber;
    private String productCategory; // e.g., "PCB_CIRCUIT", "ENGINE_VALVE", "DISPLAY_PANEL"
    private double dimensionalToleranceMm; // measured deviation in mm
    private List<Defect> detectedDefects;
    private String finalVerdict; // "PASSED", "DEFECTIVE", "NEEDS_MANUAL_REVIEW"

    public InspectionItem(String serialNumber, String productCategory, double dimensionalToleranceMm) {
        if (serialNumber == null || serialNumber.trim().isEmpty()) {
            throw new SensorDataCorruptException("Item serial number cannot be empty.");
        }
        this.serialNumber = serialNumber;
        this.productCategory = productCategory;
        this.dimensionalToleranceMm = dimensionalToleranceMm;
        this.detectedDefects = new ArrayList<>();
        this.finalVerdict = "PENDING";
    }

    public void addDefect(Defect defect) {
        this.detectedDefects.add(defect);
    }

    public String getSerialNumber() { return serialNumber; }
    public String getProductCategory() { return productCategory; }
    public double getDimensionalToleranceMm() { return dimensionalToleranceMm; }
    public List<Defect> getDetectedDefects() { return detectedDefects; }
    public String getFinalVerdict() { return finalVerdict; }
    public void setFinalVerdict(String finalVerdict) { this.finalVerdict = finalVerdict; }
}

// ============================================================================
// 3. INHERITANCE & POLYMORPHISM: AI INSPECTOR HIERARCHY (Module 5)
// ============================================================================
abstract class VisualInspector {
    protected String inspectorName;
    protected String modelVersion;

    public VisualInspector(String inspectorName, String modelVersion) {
        this.inspectorName = inspectorName;
        this.modelVersion = modelVersion;
    }

    // Polymorphic inspection method
    public abstract void inspect(InspectionItem item) throws CriticalQualityFaultException;

    public void displayInspectorDetails() {
        System.out.printf("[INSPECTOR ONLINE] %s | Vision Model: %s%n", inspectorName, modelVersion);
    }
}

// Specialized Surface Defect AI (Deep CNN model simulation)
class SurfaceDefectDetector extends VisualInspector {
    public SurfaceDefectDetector() {
        super("AI Surface Anomaly Model", "v3.2-ResNet-Optical");
    }

    @Override
    public void inspect(InspectionItem item) throws CriticalQualityFaultException {
        // String analysis: checking product category requirements
        if (item.getProductCategory().equalsIgnoreCase("PCB_CIRCUIT")) {
            // Simulated AI optical inference check
            if (item.getSerialNumber().endsWith("9")) { 
                Defect defect = new Defect("Solder Bridge / Short Circuit", 0.96, "CRITICAL");
                item.addDefect(defect);
                throw new CriticalQualityFaultException("Safety hazard on " + item.getSerialNumber() + ": " + defect);
            } else if (item.getSerialNumber().endsWith("4")) {
                item.addDefect(new Defect("Surface Scratch / Oxidation", 0.81, "MINOR"));
            }
        }
    }
}

// Specialized Dimensional Accuracy AI
class DimensionalToleranceInspector extends VisualInspector {
    private static final double MAX_TOLERANCE_MM = 0.05; // 50 microns limit

    public DimensionalToleranceInspector() {
        super("Laser Photogrammetry Inspector", "v1.8-PrecisionFit");
    }

    @Override
    public void inspect(InspectionItem item) {
        if (Math.abs(item.getDimensionalToleranceMm()) > MAX_TOLERANCE_MM) {
            String severity = Math.abs(item.getDimensionalToleranceMm()) > 0.10 ? "MAJOR" : "MINOR";
            item.addDefect(new Defect("Dimensional Warpage (" + item.getDimensionalToleranceMm() + "mm)", 0.99, severity));
        }
    }
}

// Specialized Component Integrity AI
class ComponentIntegrityInspector extends VisualInspector {
    public ComponentIntegrityInspector() {
        super("YOLOv8 Component Presence Detector", "v4.0-EdgeVision");
    }

    @Override
    public void inspect(InspectionItem item) {
        if (item.getSerialNumber().endsWith("7")) {
            item.addDefect(new Defect("Missing Micro-Capacitor", 0.92, "MAJOR"));
        }
    }
}

// ============================================================================
// 4. STRINGS & ARRAYS QUALITY ANALYTICS (Modules 1, 2, 3)
// ============================================================================
class QualityAnalyticsEngine {

    // 1D & 2D Arrays for tracking inspection statistics across production shifts
    // Rows = Shifts (Morning, Evening, Night), Cols = [Total, Passed, Defective]
    private int[][] shiftStatistics = new int[3][3];
    private String[] shiftNames = {"Morning Shift", "Evening Shift", "Night Shift"};

    // Common defect classification strings
    private static final String[] KNOWN_DEFECT_PATTERNS = {
        "solder", "scratch", "warpage", "missing", "misalignment", "crack"
    };

    public void recordItem(int shiftIndex, InspectionItem item) {
        shiftStatistics[shiftIndex][0]++; // Total
        if ("PASSED".equalsIgnoreCase(item.getFinalVerdict())) {
            shiftStatistics[shiftIndex][1]++; // Passed
        } else {
            shiftStatistics[shiftIndex][2]++; // Defective
        }
    }

    // String manipulation to extract root cause keyword from logs
    public String extractRootCauseKeyword(String rawDefectDescription) {
        String cleanText = rawDefectDescription.toLowerCase().trim();
        for (String pattern : KNOWN_DEFECT_PATTERNS) {
            if (cleanText.contains(pattern)) {
                return pattern.toUpperCase();
            }
        }
        return "GENERAL_FAULT";
    }

    public void printShiftMatrixReport() {
        System.out.println("\n==================================================================");
        System.out.println("        PRODUCTION SHIFT QUALITY MATRIX (2D ARRAY REPORT)         ");
        System.out.println("==================================================================");
        System.out.printf("%-18s %-12s %-12s %-12s %-10s%n", "SHIFT", "INSPECTED", "PASSED", "DEFECTIVE", "YIELD %");
        System.out.println("------------------------------------------------------------------");

        for (int i = 0; i < shiftStatistics.length; i++) {
            int total = shiftStatistics[i][0];
            int passed = shiftStatistics[i][1];
            int defective = shiftStatistics[i][2];
            double yield = (total == 0) ? 100.0 : ((double) passed / total) * 100.0;

            System.out.printf("%-18s %-12d %-12d %-12d %6.2f%%%n",
                    shiftNames[i], total, passed, defective, yield);
        }
        System.out.println("==================================================================");
    }
}

// ============================================================================
// 5. FILE HANDLING & MULTITHREADED BACKUP SYSTEM (Module 7)
// ============================================================================
class QualityAuditLogger {
    private static final String LOG_FILE = "inspection_records.csv";
    private static final String BACKUP_FILE = "inspection_backup.csv";
    private final Object fileLock = new Object();

    public QualityAuditLogger() {
        // Initialize log file with CSV headers
        synchronized (fileLock) {
            try (PrintWriter writer = new PrintWriter(new FileWriter(LOG_FILE, false))) {
                writer.println("Timestamp,SerialNumber,Category,ToleranceMm,Verdict,DefectsCount,DefectDetails");
            } catch (IOException e) {
                System.err.println("[FILE ERROR] Unable to initialize log file: " + e.getMessage());
            }
        }
    }

    public void appendRecord(InspectionItem item) {
        synchronized (fileLock) {
            try (PrintWriter writer = new PrintWriter(new FileWriter(LOG_FILE, true))) {
                String timestamp = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date());
                StringBuilder defectSummary = new StringBuilder();

                for (Defect d : item.getDetectedDefects()) {
                    defectSummary.append(d.getDefectType()).append("; ");
                }

                String cleanDefects = defectSummary.toString().replace(",", " ");

                writer.printf("%s,%s,%s,%.4f,%s,%d,\"%s\"%n",
                        timestamp,
                        item.getSerialNumber(),
                        item.getProductCategory(),
                        item.getDimensionalToleranceMm(),
                        item.getFinalVerdict(),
                        item.getDetectedDefects().size(),
                        cleanDefects);
            } catch (IOException e) {
                System.err.println("[FILE ERROR] Could not write audit log: " + e.getMessage());
            }
        }
    }

    // Method to create automated backup
    public void backupLogFile() {
        synchronized (fileLock) {
            File source = new File(LOG_FILE);
            if (!source.exists()) return;

            try (BufferedReader reader = new BufferedReader(new FileReader(source));
                 BufferedWriter writer = new BufferedWriter(new FileWriter(BACKUP_FILE))) {

                String line;
                while ((line = reader.readLine()) != null) {
                    writer.write(line);
                    writer.newLine();
                }
                System.out.println("[BACKUP SERVICE] Auto-backup successfully created: " + BACKUP_FILE);
            } catch (IOException e) {
                System.err.println("[BACKUP FAILED] " + e.getMessage());
            }
        }
    }
}

// Background Thread for Periodic File Backup
class AutoBackupTask implements Runnable {
    private final QualityAuditLogger logger;
    private volatile boolean running = true;

    public AutoBackupTask(QualityAuditLogger logger) {
        this.logger = logger;
    }

    public void stop() {
        this.running = false;
    }

    @Override
    public void run() {
        while (running) {
            try {
                Thread.sleep(4000); // Trigger backup every 4 seconds
                logger.backupLogFile();
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                break;
            }
        }
    }
}

// Multithreaded Conveyor Belt Inspection Worker
class ConveyorInspectionWorker implements Runnable {
    private final BlockingQueue<InspectionItem> conveyorBelt;
    private final List<VisualInspector> inspectors;
    private final QualityAuditLogger logger;
    private final QualityAnalyticsEngine analyticsEngine;
    private final int workerId;

    public ConveyorInspectionWorker(int workerId,
                                  BlockingQueue<InspectionItem> conveyorBelt,
                                  List<VisualInspector> inspectors,
                                  QualityAuditLogger logger,
                                  QualityAnalyticsEngine analyticsEngine) {
        this.workerId = workerId;
        this.conveyorBelt = conveyorBelt;
        this.inspectors = inspectors;
        this.logger = logger;
        this.analyticsEngine = analyticsEngine;
    }

    @Override
    public void run() {
        while (true) {
            try {
                InspectionItem item = conveyorBelt.poll(2, TimeUnit.SECONDS);
                if (item == null) {
                    break; // Queue drained
                }

                System.out.printf("[LINE WORKER #%d] Scanning Item: %s (%s)...%n", 
                        workerId, item.getSerialNumber(), item.getProductCategory());

                // Execute polymorphic inspections
                boolean criticalFailure = false;
                for (VisualInspector inspector : inspectors) {
                    try {
                        inspector.inspect(item);
                    } catch (CriticalQualityFaultException e) {
                        System.err.printf("[LINE WORKER #%d] ⚠ ALERT: %s%n", workerId, e.getMessage());
                        criticalFailure = true;
                    }
                }

                // Determine final quality verdict
                if (criticalFailure) {
                    item.setFinalVerdict("REJECTED_CRITICAL");
                } else if (!item.getDetectedDefects().isEmpty()) {
                    item.setFinalVerdict("DEFECTIVE_REWORK");
                } else {
                    item.setFinalVerdict("PASSED");
                }

                // Save to CSV log & Analytics
                logger.appendRecord(item);
                analyticsEngine.recordItem(0, item); // Record under Morning shift

                System.out.printf("[LINE WORKER #%d] Finished %s -> VERDICT: [%s] (Defects: %d)%n%n",
                        workerId, item.getSerialNumber(), item.getFinalVerdict(), item.getDetectedDefects().size());

                Thread.sleep(600); // Simulate processing time per unit
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                break;
            }
        }
    }
}

// ============================================================================
// 6. MAIN CONTROLLER & APPLICATION ENTRYPOINT
// ============================================================================
public class IndustrialVisualInspectionSystem {

    public static void main(String[] args) {
        System.out.println("==================================================================");
        System.out.println("  AI-POWERED INDUSTRIAL VISUAL INSPECTION & QUALITY SYSTEM        ");
        System.out.println("==================================================================");

        // 1. Initialize AI Inspectors (Polymorphic list)
        List<VisualInspector> aiInspectors = new ArrayList<>();
        aiInspectors.add(new SurfaceDefectDetector());
        aiInspectors.add(new DimensionalToleranceInspector());
        aiInspectors.add(new ComponentIntegrityInspector());

        for (VisualInspector vi : aiInspectors) {
            vi.displayInspectorDetails();
        }

        // 2. Initialize Audit Logger, Analytics & Conveyor Queue
        QualityAuditLogger logger = new QualityAuditLogger();
        QualityAnalyticsEngine analyticsEngine = new QualityAnalyticsEngine();
        BlockingQueue<InspectionItem> conveyorBelt = new LinkedBlockingQueue<>();

        // 3. Start Background Auto-Backup Thread (Multithreading & File I/O)
        AutoBackupTask backupTask = new AutoBackupTask(logger);
        Thread backupThread = new Thread(backupTask, "Backup-Daemon");
        backupThread.setDaemon(true);
        backupThread.start();
        System.out.println("[SYSTEM] Automated Data Backup Thread launched.\n");

        // 4. Populate Simulated Conveyor Belt with Manufactured Units
        conveyorBelt.offer(new InspectionItem("PCB-SN-1001", "PCB_CIRCUIT", 0.012));
        conveyorBelt.offer(new InspectionItem("PCB-SN-1004", "PCB_CIRCUIT", 0.085)); // Scratch + Warpage
        conveyorBelt.offer(new InspectionItem("PCB-SN-1007", "PCB_CIRCUIT", -0.010)); // Missing Cap
        conveyorBelt.offer(new InspectionItem("ENG-SN-5002", "ENGINE_VALVE", 0.005)); // Clean Pass
        conveyorBelt.offer(new InspectionItem("PCB-SN-1009", "PCB_CIRCUIT", 0.004)); // Solder bridge (Critical)
        conveyorBelt.offer(new InspectionItem("ENG-SN-5008", "ENGINE_VALVE", 0.120)); // Warpage
        conveyorBelt.offer(new InspectionItem("DSP-SN-9003", "DISPLAY_PANEL", 0.002)); // Clean Pass

        // 5. Spawn Multiple Inspection Line Threads (Simulating parallel inspection bays)
        Thread worker1 = new Thread(new ConveyorInspectionWorker(1, conveyorBelt, aiInspectors, logger, analyticsEngine));
        Thread worker2 = new Thread(new ConveyorInspectionWorker(2, conveyorBelt, aiInspectors, logger, analyticsEngine));

        System.out.println("--- STARTING DUAL-BAY PARALLEL INSPECTION ---");
        worker1.start();
        worker2.start();

        try {
            // Wait for both worker threads to complete inspection
            worker1.join();
            worker2.join();
        } catch (InterruptedException e) {
            System.err.println("Main inspection sequence interrupted: " + e.getMessage());
        }

        // 6. Generate Quality Analytics and Reports
        analyticsEngine.printShiftMatrixReport();

        // 7. Flush final backup
        backupTask.stop();
        logger.backupLogFile();

        System.out.println("\n[SYSTEM SUMMARY]");
        System.out.println(" Inspection records saved to: inspection_records.csv");
        System.out.println(" Backup copy synchronized to: inspection_backup.csv");
        System.out.println(" All units processed. Industrial inspection line offline.");
    }
}
