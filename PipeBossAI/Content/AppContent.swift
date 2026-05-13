import Foundation

enum AppContent {
    enum ProductIDs {
        static let proMonthly = "com.pipebossai.pro.monthly"
        static let proYearly = "com.pipebossai.pro.yearly"
        static let cityExpansion = "com.pipebossai.pack.city"
        static let advancedTools = "com.pipebossai.pack.advancedtools"
        static let emergencyJobs = "com.pipebossai.pack.emergency"
        static let businessOwnerMode = "com.pipebossai.pack.businessowner"
    }

    static let copy = AppCopy()

    static let onboardingPages: [OnboardingPage] = [
        OnboardingPage(
            id: "career",
            title: "Start as an apprentice",
            subtitle: "Take realistic plumbing jobs, build confidence, and learn the practical choices behind each fix.",
            iconSystemName: "figure.2.and.child.holdinghands"
        ),
        OnboardingPage(
            id: "diagnose",
            title: "Diagnose before you repair",
            subtitle: "Inspect symptoms, pick the right tools, answer diagnosis checks, and avoid expensive rework.",
            iconSystemName: "stethoscope"
        ),
        OnboardingPage(
            id: "business",
            title: "Grow a real trade career",
            subtitle: "Earn XP, upgrade your kit, improve customer ratings, and unlock advanced commercial scenarios.",
            iconSystemName: "briefcase.fill"
        )
    ]

    static let storeProducts: [SubscriptionProduct] = [
        SubscriptionProduct(
            id: "pro-monthly",
            productID: ProductIDs.proMonthly,
            displayName: "PipeBoss Pro Monthly",
            subtitle: "Full training access with flexible monthly billing.",
            pricePlaceholder: "$6.99 / month",
            kind: .monthlySubscription,
            benefits: [
                "Unlimited jobs",
                "Advanced and heating scenarios",
                "Commercial contracts",
                "Exam-style quizzes",
                "Mentor hints",
                "No ads"
            ]
        ),
        SubscriptionProduct(
            id: "pro-yearly",
            productID: ProductIDs.proYearly,
            displayName: "PipeBoss Pro Yearly",
            subtitle: "Best value for trade school learners and company training.",
            pricePlaceholder: "$49.99 / year",
            kind: .yearlySubscription,
            benefits: [
                "Everything in PipeBoss Pro",
                "Detailed performance analytics placeholder",
                "Cloud progress sync placeholder",
                "Priority access to new modules"
            ]
        ),
        SubscriptionProduct(
            id: "city-expansion",
            productID: ProductIDs.cityExpansion,
            displayName: "City Expansion Pack",
            subtitle: "Adds dense apartment, restaurant, and mixed-use jobs.",
            pricePlaceholder: "$9.99 one time",
            kind: .nonConsumable,
            benefits: ["City job board", "Urban fault patterns", "Higher reward jobs"]
        ),
        SubscriptionProduct(
            id: "advanced-tools",
            productID: ProductIDs.advancedTools,
            displayName: "Advanced Tool Pack",
            subtitle: "Unlock specialist tools for faster diagnosis.",
            pricePlaceholder: "$7.99 one time",
            kind: .nonConsumable,
            benefits: ["Thermal camera", "Press tool", "Drain camera", "Pipe freeze kit"]
        ),
        SubscriptionProduct(
            id: "emergency-pack",
            productID: ProductIDs.emergencyJobs,
            displayName: "Emergency Jobs Pack",
            subtitle: "Burst pipes, callouts, urgent isolation, and triage.",
            pricePlaceholder: "$5.99 one time",
            kind: .nonConsumable,
            benefits: ["Emergency scenarios", "Higher pressure decisions", "Bonus XP"]
        ),
        SubscriptionProduct(
            id: "business-owner",
            productID: ProductIDs.businessOwnerMode,
            displayName: "Business Owner Mode",
            subtitle: "Quoting, scheduling, staffing, and customer reputation challenges.",
            pricePlaceholder: "$11.99 one time",
            kind: .nonConsumable,
            benefits: ["Business upgrades", "Quote challenges", "Contract strategy"]
        )
    ]

    static let tools: [ToolItem] = [
        ToolItem(id: "adjustable-wrench", name: "Adjustable Wrench", category: .handTools, summary: "Starter spanner for compression nuts, valves, and simple fittings.", cost: 0, requiredLevel: 1, performanceBoost: 1, isStarterTool: true, iconSystemName: "wrench.adjustable.fill"),
        ToolItem(id: "screwdriver-set", name: "Screwdriver Set", category: .handTools, summary: "Useful for access panels, cistern parts, brackets, and simple trim.", cost: 0, requiredLevel: 1, performanceBoost: 1, isStarterTool: true, iconSystemName: "screwdriver.fill"),
        ToolItem(id: "plunger", name: "Plunger", category: .drainage, summary: "First-line tool for simple sink, basin, and WC blockages.", cost: 0, requiredLevel: 1, performanceBoost: 1, isStarterTool: true, iconSystemName: "arrow.down.circle.fill"),
        ToolItem(id: "bucket", name: "Bucket and Towels", category: .handTools, summary: "Keeps water contained while you isolate, drain, or open fittings.", cost: 0, requiredLevel: 1, performanceBoost: 1, isStarterTool: true, iconSystemName: "drop.fill"),
        ToolItem(id: "ptfe-tape", name: "PTFE Tape", category: .handTools, summary: "Sealant tape for suitable threaded joints when specified.", cost: 0, requiredLevel: 1, performanceBoost: 1, isStarterTool: true, iconSystemName: "seal.fill"),
        ToolItem(id: "radiator-key", name: "Radiator Key", category: .heating, summary: "Bleeds trapped air from radiators after safe pressure checks.", cost: 0, requiredLevel: 1, performanceBoost: 1, isStarterTool: true, iconSystemName: "key.fill"),
        ToolItem(id: "pipe-cutter", name: "Pipe Cutter", category: .handTools, summary: "Makes square cuts on copper or plastic pipe for neat repairs.", cost: 180, requiredLevel: 2, performanceBoost: 2, isStarterTool: false, iconSystemName: "scissors"),
        ToolItem(id: "drain-auger", name: "Drain Auger", category: .drainage, summary: "Clears deeper clogs beyond the trap when plunging is not enough.", cost: 240, requiredLevel: 3, performanceBoost: 2, isStarterTool: false, iconSystemName: "move.3d"),
        ToolItem(id: "pressure-gauge", name: "Pressure Gauge", category: .testing, summary: "Checks static and dynamic pressure before choosing a repair.", cost: 320, requiredLevel: 4, performanceBoost: 2, isStarterTool: false, iconSystemName: "gauge.medium"),
        ToolItem(id: "inspection-camera", name: "Inspection Camera", category: .testing, summary: "Finds hidden leaks, blockages, and pipe routes with less disruption.", cost: 520, requiredLevel: 5, performanceBoost: 3, isStarterTool: false, iconSystemName: "camera.macro"),
        ToolItem(id: "pipe-freeze-kit", name: "Pipe Freeze Kit", category: .specialist, summary: "Creates a temporary ice plug when isolation valves are unavailable.", cost: 650, requiredLevel: 7, performanceBoost: 3, isStarterTool: false, iconSystemName: "snowflake"),
        ToolItem(id: "press-tool", name: "Press Tool", category: .specialist, summary: "Speeds up approved press-fit installations when compatible fittings are used.", cost: 900, requiredLevel: 8, performanceBoost: 4, isStarterTool: false, iconSystemName: "hammer.fill"),
        ToolItem(id: "thermal-camera", name: "Thermal Camera", category: .testing, summary: "Helps trace hot water runs, cold spots, and concealed heating faults.", cost: 1100, requiredLevel: 10, performanceBoost: 4, isStarterTool: false, iconSystemName: "camera.filters"),
        ToolItem(id: "combustion-analyzer", name: "Combustion Analyzer", category: .heating, summary: "Placeholder for qualified heating modules and regulated safety checks.", cost: 1400, requiredLevel: 12, performanceBoost: 4, isStarterTool: false, iconSystemName: "flame.fill"),
        ToolItem(id: "wet-vac", name: "Wet Vacuum", category: .drainage, summary: "Controls spills and standing water during urgent callouts.", cost: 450, requiredLevel: 5, performanceBoost: 2, isStarterTool: false, iconSystemName: "wind"),
        ToolItem(id: "soldering-kit", name: "Soldering Kit", category: .specialist, summary: "For training scenarios using safe hot-work planning and compatible pipework.", cost: 700, requiredLevel: 8, performanceBoost: 3, isStarterTool: false, iconSystemName: "flame.circle.fill"),
        ToolItem(id: "pipe-sizing-wheel", name: "Pipe Sizing Wheel", category: .testing, summary: "Compares demand, length, and pressure drop in sizing challenges.", cost: 380, requiredLevel: 6, performanceBoost: 2, isStarterTool: false, iconSystemName: "circle.hexagongrid.fill"),
        ToolItem(id: "drain-camera", name: "Drain Camera", category: .drainage, summary: "Inspects underground and commercial drainage routes.", cost: 1250, requiredLevel: 11, performanceBoost: 4, isStarterTool: false, iconSystemName: "video.fill")
    ]

    static let upgrades: [Upgrade] = [
        Upgrade(id: "parts-bins", name: "Organized Parts Bins", category: .workshop, summary: "Keep common washers, traps, and fittings ready for fast jobs.", cost: 260, requiredLevel: 2, effectDescription: "+5% coin bonus on beginner jobs.", iconSystemName: "shippingbox.fill", isPremium: false),
        Upgrade(id: "apprentice-course", name: "Evening Skills Course", category: .training, summary: "Boosts confidence with pressure, drainage, and customer communication.", cost: 420, requiredLevel: 3, effectDescription: "+10 XP on correct jobs.", iconSystemName: "graduationcap.fill", isPremium: false),
        Upgrade(id: "branded-van", name: "Branded Van Wrap", category: .vehicle, summary: "A professional look helps customer trust and repeat work.", cost: 620, requiredLevel: 5, effectDescription: "+0.1 reputation on perfect jobs.", iconSystemName: "truck.box.fill", isPremium: false),
        Upgrade(id: "review-system", name: "Review Follow-Up System", category: .marketing, summary: "Ask happy customers for ratings after clean, safe jobs.", cost: 720, requiredLevel: 6, effectDescription: "+5% reputation gain.", iconSystemName: "star.bubble.fill", isPremium: false),
        Upgrade(id: "scheduling-tablet", name: "Scheduling Tablet", category: .business, summary: "Plan parts, travel, and callbacks more accurately.", cost: 840, requiredLevel: 7, effectDescription: "+1 daily energy.", iconSystemName: "ipad.landscape", isPremium: false),
        Upgrade(id: "emergency-kit", name: "Emergency Callout Kit", category: .vehicle, summary: "Isolation tags, clamps, spill control, and temporary repair supplies.", cost: 1200, requiredLevel: 9, effectDescription: "Unlocks faster emergency job starts.", iconSystemName: "cross.case.fill", isPremium: true),
        Upgrade(id: "commercial-insurance", name: "Commercial Insurance", category: .business, summary: "Required before taking higher-value maintenance contracts.", cost: 1500, requiredLevel: 11, effectDescription: "Unlocks commercial contract chain.", iconSystemName: "building.2.crop.circle.fill", isPremium: true),
        Upgrade(id: "business-owner-mode", name: "Business Owner Desk", category: .business, summary: "Quote work, manage schedules, and balance profit with reputation.", cost: 1800, requiredLevel: 13, effectDescription: "Unlocks owner-mode decision jobs.", iconSystemName: "briefcase.fill", isPremium: true)
    ]

    static let learningCards: [LearningCard] = [
        LearningCard(id: "safety-basics", title: "Safety First", topic: "Safety", summary: "Stop, isolate, protect the property, and check the limits of your competence.", bulletPoints: ["Identify water, heat, electrical, and hygiene risks.", "Use isolation valves before opening pipework.", "Escalate regulated or unsafe work."], requiredLevel: 1, isPremium: false, iconSystemName: "shield.lefthalf.filled"),
        LearningCard(id: "hand-tool-basics", title: "Basic Tool Kit", topic: "Tools", summary: "Start with reliable hand tools and learn when a specialist tool is worth the cost.", bulletPoints: ["Use the right jaw size to avoid rounding nuts.", "Keep towels and a bucket ready before loosening fittings.", "Replace worn consumables early."], requiredLevel: 1, isPremium: false, iconSystemName: "wrench.and.screwdriver.fill"),
        LearningCard(id: "pipe-materials", title: "Pipe Materials", topic: "Materials", summary: "Copper, plastic, and flexible connectors behave differently under heat and pressure.", bulletPoints: ["Match fittings to pipe material.", "Support pipework to prevent stress.", "Follow manufacturer installation rules."], requiredLevel: 2, isPremium: false, iconSystemName: "square.stack.3d.up.fill"),
        LearningCard(id: "fittings", title: "Fittings and Joints", topic: "Fittings", summary: "Most small leaks come from poor seating, wrong inserts, damaged olives, or over-tightening.", bulletPoints: ["Inspect before tightening.", "Use inserts on compatible plastic pipe.", "Do not reuse damaged seals."], requiredLevel: 3, isPremium: false, iconSystemName: "link.circle.fill"),
        LearningCard(id: "pressure", title: "Pressure Basics", topic: "Pressure", summary: "Pressure problems need measurements, not guesses.", bulletPoints: ["Compare static and flow pressure.", "Check filters and partially closed valves.", "Avoid exceeding appliance limits."], requiredLevel: 4, isPremium: false, iconSystemName: "gauge.medium"),
        LearningCard(id: "drainage", title: "Drainage Flow", topic: "Drainage", summary: "Good drainage depends on clear traps, correct falls, venting, and clean routes.", bulletPoints: ["Remove trap debris first.", "Avoid chemical shortcuts in training.", "Look for repeated blockages upstream."], requiredLevel: 4, isPremium: false, iconSystemName: "water.waves"),
        LearningCard(id: "customer-communication", title: "Customer Briefs", topic: "Communication", summary: "A good plumber asks clear questions and explains options without overpromising.", bulletPoints: ["Confirm symptoms and timing.", "Explain disruption before starting.", "Document safety warnings."], requiredLevel: 5, isPremium: false, iconSystemName: "person.wave.2.fill"),
        LearningCard(id: "water-hammer", title: "Water Hammer", topic: "Fault Diagnosis", summary: "Banging pipes often point to loose pipework, high pressure, or fast-closing valves.", bulletPoints: ["Reproduce the symptom.", "Measure pressure.", "Secure pipework where accessible."], requiredLevel: 6, isPremium: false, iconSystemName: "waveform.path.ecg"),
        LearningCard(id: "heating-basics", title: "Heating Basics", topic: "Heating", summary: "Heating faults need safe checks around pressure, air, sludge, pumps, and controls.", bulletPoints: ["Check system pressure first.", "Bleed air only when appropriate.", "Know when regulated heating work needs a qualified professional."], requiredLevel: 7, isPremium: true, iconSystemName: "flame.fill"),
        LearningCard(id: "fault-diagnosis", title: "Fault Trees", topic: "Diagnosis", summary: "Work from simple observable evidence toward invasive checks.", bulletPoints: ["Start with isolation and symptoms.", "Change one variable at a time.", "Retest after every repair."], requiredLevel: 8, isPremium: false, iconSystemName: "list.bullet.clipboard.fill"),
        LearningCard(id: "boiler-pressure", title: "Boiler Pressure", topic: "Heating", summary: "Low pressure may be a symptom, not the root cause.", bulletPoints: ["Look for leaks before topping up.", "Use manufacturer guidance.", "Escalate gas or combustion work."], requiredLevel: 9, isPremium: true, iconSystemName: "thermometer.medium"),
        LearningCard(id: "commercial-maintenance", title: "Commercial Maintenance", topic: "Commercial", summary: "Commercial jobs reward documentation, planned isolation, and clear handover.", bulletPoints: ["Confirm site rules.", "Protect public areas.", "Record what was inspected and repaired."], requiredLevel: 11, isPremium: true, iconSystemName: "building.2.fill"),
        LearningCard(id: "quoting", title: "Quoting Basics", topic: "Business", summary: "A clear quote protects the customer and the business.", bulletPoints: ["Separate labour, materials, and contingency.", "Name exclusions.", "Confirm access and working hours."], requiredLevel: 12, isPremium: false, iconSystemName: "doc.text.fill"),
        LearningCard(id: "exam-readiness", title: "Exam-Style Checks", topic: "Assessment", summary: "Exam questions often test safe order of operations.", bulletPoints: ["Isolate before repair.", "Measure before adjusting.", "Escalate regulated work."], requiredLevel: 14, isPremium: true, iconSystemName: "checkmark.seal.fill")
    ]

    static let leaderboard: [LeaderboardEntry] = [
        LeaderboardEntry(id: "1", rank: 1, name: "A. Morgan", level: 19, reputation: 4.9, badge: "Master Fixer"),
        LeaderboardEntry(id: "2", rank: 2, name: "J. Patel", level: 17, reputation: 4.8, badge: "Drain Pro"),
        LeaderboardEntry(id: "3", rank: 3, name: "S. Reed", level: 16, reputation: 4.7, badge: "Heating Ace"),
        LeaderboardEntry(id: "4", rank: 4, name: "L. Carter", level: 14, reputation: 4.6, badge: "Commercial Ready"),
        LeaderboardEntry(id: "5", rank: 5, name: "You", level: 1, reputation: 3.5, badge: "Rising Apprentice")
    ]

    static let jobs: [JobScenario] = [
        JobScenario(
            id: "beginner-leak-under-sink",
            title: "Leaking Pipe Under Sink",
            customerComplaint: "Water appears in the cabinet whenever the kitchen tap runs.",
            difficulty: .beginner,
            category: .leaks,
            requiredLevel: 1,
            requiredTools: ["adjustable-wrench", "bucket", "ptfe-tape"],
            symptoms: ["Drips form below the compression joint.", "Trap is dry above the joint.", "Leak worsens when hot tap runs."],
            diagnosisQuestion: question("leak-under-sink-diagnosis", "What is the most likely fault?", [option("loose-compression", "Loose compression joint", "The nut and olive are not sealing correctly."), option("blocked-trap", "Blocked trap", "A blockage would usually slow drainage."), option("failed-tap-cartridge", "Failed tap cartridge", "This would leak from the tap body, not the pipe joint.")], "loose-compression", "The leak only appears around the compression joint while water passes through that section."),
            repairOptions: [option("isolate-reseat-tighten", "Isolate, inspect, reseat, and tighten", "Contain water, isolate, inspect the olive and pipe, then remake the joint."), option("tighten-hard", "Over-tighten the nut", "This can crush fittings and make the leak worse."), option("seal-outside", "Smear sealant outside the joint", "External sealant does not fix the sealing face.")],
            correctRepairID: "isolate-reseat-tighten",
            timeLimitMinutes: 8,
            rewardCoins: 90,
            rewardXP: 75,
            learningTip: "Compression joints seal inside the fitting. Inspect and remake the joint instead of hiding the drip.",
            mentorHint: "Trace the water to the highest wet point before choosing the repair.",
            safetyWarning: "Isolate the water supply and protect the cabinet before opening the joint.",
            isPremium: false,
            isFreeStarterJob: true,
            iconSystemName: "drop.fill"
        ),
        JobScenario(
            id: "beginner-slow-basin-drain",
            title: "Slow Bathroom Basin Drain",
            customerComplaint: "The basin fills up and drains away slowly after shaving.",
            difficulty: .beginner,
            category: .drainage,
            requiredLevel: 1,
            requiredTools: ["plunger", "bucket"],
            symptoms: ["No other fixtures are affected.", "Water drains after one minute.", "Trap area smells slightly stale."],
            diagnosisQuestion: question("slow-basin-diagnosis", "Where should you inspect first?", [option("basin-trap", "Basin trap", "Hair and soap often collect here."), option("main-sewer", "Main sewer", "A main issue would affect more fixtures."), option("water-pressure", "Incoming pressure", "Pressure does not control drain speed.")], "basin-trap", "A single slow basin usually points to a local trap or waste restriction."),
            repairOptions: [option("clear-trap", "Remove and clear the trap", "Catch water, clean the trap, refit seals, and test flow."), option("chemical-only", "Use chemicals only", "This avoids diagnosis and can create safety issues."), option("replace-tap", "Replace the tap", "The tap is not causing slow waste flow.")],
            correctRepairID: "clear-trap",
            timeLimitMinutes: 7,
            rewardCoins: 70,
            rewardXP: 60,
            learningTip: "For one slow fixture, start local. The trap tells you a lot before you escalate.",
            mentorHint: "Ask whether nearby fixtures drain normally.",
            safetyWarning: "Wear gloves and avoid mixing unknown drain chemicals.",
            isPremium: false,
            isFreeStarterJob: true,
            iconSystemName: "water.waves"
        ),
        JobScenario(
            id: "beginner-running-toilet",
            title: "Running Toilet Cistern",
            customerComplaint: "The toilet keeps trickling into the pan after flushing.",
            difficulty: .beginner,
            category: .fixtures,
            requiredLevel: 1,
            requiredTools: ["screwdriver-set", "bucket"],
            symptoms: ["Water trickles into the pan.", "Cistern level reaches the overflow.", "Float arm sits too high."],
            diagnosisQuestion: question("running-toilet-diagnosis", "What is the likely issue?", [option("fill-valve-set-high", "Fill valve set too high", "The cistern overfills into the overflow."), option("blocked-waste", "Blocked waste", "The pan clears normally after flushing."), option("low-pressure", "Low pressure", "Low pressure would slow filling, not cause overflow.")], "fill-valve-set-high", "The water level is reaching the overflow, so the fill control needs adjustment or repair."),
            repairOptions: [option("adjust-fill-valve", "Adjust or repair the fill valve", "Set the water level correctly, then flush test."), option("seal-overflow", "Block the overflow", "The overflow is a safety route and must not be blocked."), option("replace-pan", "Replace the toilet pan", "The fault is in the cistern fill control.")],
            correctRepairID: "adjust-fill-valve",
            timeLimitMinutes: 8,
            rewardCoins: 80,
            rewardXP: 65,
            learningTip: "A constant trickle often wastes a lot of water. Check the fill level before replacing parts.",
            mentorHint: "Look for whether the water stops below or above the overflow point.",
            safetyWarning: "Do not block overflow paths; correct the cause of overfilling.",
            isPremium: false,
            isFreeStarterJob: true,
            iconSystemName: "toilet.fill"
        ),
        JobScenario(
            id: "beginner-radiator-cold-top",
            title: "Radiator Cold at Top",
            customerComplaint: "The upstairs radiator is warm at the bottom but cold at the top.",
            difficulty: .beginner,
            category: .heating,
            requiredLevel: 1,
            requiredTools: ["radiator-key", "bucket"],
            symptoms: ["Top section stays cold.", "Pipe valves feel warm.", "Gurgling noise after heating starts."],
            diagnosisQuestion: question("radiator-cold-top-diagnosis", "What does the cold top suggest?", [option("trapped-air", "Trapped air", "Air collects at the high point and stops circulation."), option("blocked-drain", "Blocked drain", "Drainage is not part of this heating symptom."), option("broken-radiator", "Broken radiator shell", "The pattern points to air before replacement.")], "trapped-air", "A warm bottom and cold top is the classic sign of trapped air."),
            repairOptions: [option("bleed-check-pressure", "Bleed air and check system pressure", "Vent carefully, catch water, then confirm pressure is safe."), option("open-fully-ignore", "Open the valve and leave", "This misses trapped air and pressure checks."), option("remove-radiator", "Remove the radiator", "Start with the simple non-invasive fix.")],
            correctRepairID: "bleed-check-pressure",
            timeLimitMinutes: 9,
            rewardCoins: 85,
            rewardXP: 70,
            learningTip: "After bleeding radiators, always confirm system pressure is within the safe range.",
            mentorHint: "The temperature pattern matters: cold top usually means air.",
            safetyWarning: "Heating water can be hot. Use a cloth and follow manufacturer pressure guidance.",
            isPremium: false,
            isFreeStarterJob: true,
            iconSystemName: "thermometer.medium"
        ),
        JobScenario(
            id: "beginner-low-shower-pressure",
            title: "Low Shower Pressure",
            customerComplaint: "The shower flow has become weak over the last few weeks.",
            difficulty: .beginner,
            category: .fixtures,
            requiredLevel: 1,
            requiredTools: ["screwdriver-set", "bucket"],
            symptoms: ["Other taps run normally.", "Shower head has visible scale.", "Flow improves briefly after wiping the faceplate."],
            diagnosisQuestion: question("low-shower-diagnosis", "What is the best first check?", [option("shower-head-scale", "Scaled shower head or filter", "Local scale can restrict flow at one outlet."), option("whole-house-pressure", "Whole-house pressure failure", "Other outlets are normal."), option("burst-main", "Burst supply main", "There is no sign of whole-property failure.")], "shower-head-scale", "One weak outlet with visible scale points to a local restriction."),
            repairOptions: [option("clean-filter-head", "Clean the filter and shower head", "Remove debris, descale safely, refit, and test."), option("increase-boiler-pressure", "Increase boiler pressure", "Do not adjust heating pressure for a shower-head restriction."), option("replace-all-pipework", "Replace all pipework", "This is excessive without measured evidence.")],
            correctRepairID: "clean-filter-head",
            timeLimitMinutes: 8,
            rewardCoins: 75,
            rewardXP: 60,
            learningTip: "When only one outlet is weak, inspect local strainers, filters, and aerators first.",
            mentorHint: "Compare the problem outlet with the nearest normal outlet.",
            safetyWarning: "Follow product instructions when descaling parts and flush before reuse.",
            isPremium: false,
            isFreeStarterJob: true,
            iconSystemName: "shower.fill"
        ),
        JobScenario(
            id: "beginner-noisy-tap",
            title: "Noisy Tap After Washer Change",
            customerComplaint: "A tap vibrates loudly after a relative tried to fix a drip.",
            difficulty: .beginner,
            category: .fixtures,
            requiredLevel: 1,
            requiredTools: ["screwdriver-set", "adjustable-wrench"],
            symptoms: ["Noise starts when the tap is half open.", "Tap was recently dismantled.", "No other fixtures make noise."],
            diagnosisQuestion: question("noisy-tap-diagnosis", "What should you suspect first?", [option("loose-washer", "Loose or wrong washer", "A loose washer can vibrate in the flow."), option("blocked-main", "Blocked main drain", "A drain fault would not vibrate a tap."), option("frozen-pipe", "Frozen pipe", "Flow is present and localized to one tap.")], "loose-washer", "The timing after a washer change and local vibration point to the tap internals."),
            repairOptions: [option("isolate-reseat-washer", "Isolate and reseat correct washer", "Check the washer, jumper, and seat before testing."), option("raise-pressure", "Raise incoming pressure", "More pressure can make vibration worse."), option("ignore-noise", "Tell customer it is normal", "New vibration after work needs inspection.")],
            correctRepairID: "isolate-reseat-washer",
            timeLimitMinutes: 7,
            rewardCoins: 70,
            rewardXP: 55,
            learningTip: "If a fault appears straight after a part change, inspect the changed part first.",
            mentorHint: "A local new symptom usually has a local recent cause.",
            safetyWarning: "Isolate water before opening tap bodies.",
            isPremium: false,
            isFreeStarterJob: true,
            iconSystemName: "speaker.wave.2.fill"
        ),
        JobScenario(
            id: "beginner-dripping-compression-joint",
            title: "Dripping Compression Joint",
            customerComplaint: "A newly fitted washing machine valve leaves a small drip overnight.",
            difficulty: .beginner,
            category: .leaks,
            requiredLevel: 2,
            requiredTools: ["adjustable-wrench", "bucket", "ptfe-tape"],
            symptoms: ["Slow drip at threaded connection.", "No spray under pressure.", "Pipe is supported and not moving."],
            diagnosisQuestion: question("compression-drip-diagnosis", "What should you check before adding more sealant?", [option("joint-faces", "Joint faces and seals", "The seal must be correct inside the fitting."), option("wall-color", "Wall color", "Cosmetic clues do not diagnose this leak."), option("tap-temperature", "Tap temperature", "Temperature is not the primary clue here.")], "joint-faces", "A drip at a new fitting needs inspection of the sealing surfaces and correct assembly."),
            repairOptions: [option("remake-joint", "Remake the joint correctly", "Isolate, inspect, replace damaged seals, and retest."), option("wrap-outside", "Wrap tape around the outside", "External wrapping is not a professional repair."), option("leave-bucket", "Leave a bucket under it", "This does not repair the fault.")],
            correctRepairID: "remake-joint",
            timeLimitMinutes: 8,
            rewardCoins: 90,
            rewardXP: 70,
            learningTip: "Small drips still matter. Remake the joint and test dry before handover.",
            mentorHint: "A new fitting leak is often assembly, not pipe failure.",
            safetyWarning: "Check appliance valves are closed before disconnecting hoses.",
            isPremium: false,
            isFreeStarterJob: true,
            iconSystemName: "drop.triangle.fill"
        ),
        JobScenario(
            id: "beginner-washing-machine-smell",
            title: "Washing Machine Trap Smell",
            customerComplaint: "The utility room smells after the washing machine drains.",
            difficulty: .beginner,
            category: .drainage,
            requiredLevel: 2,
            requiredTools: ["bucket", "screwdriver-set"],
            symptoms: ["Smell appears after discharge.", "Standpipe trap is shallow.", "No visible leak."],
            diagnosisQuestion: question("washing-machine-smell-diagnosis", "What is the likely cause?", [option("trap-seal-loss", "Trap seal being disturbed", "Poor trap arrangement can allow sewer smell."), option("hot-water-fault", "Hot water fault", "The smell follows drainage discharge."), option("tap-aerator", "Tap aerator scale", "Aerators do not cause drain smell.")], "trap-seal-loss", "The odor after discharge points to trap seal or waste arrangement issues."),
            repairOptions: [option("correct-trap-standpipe", "Correct trap and standpipe setup", "Fit and test a suitable trap arrangement with proper seal depth."), option("spray-air-freshener", "Use air freshener", "Masking odor does not fix drainage gases."), option("cap-overflow", "Cap any vent opening", "Blocking ventilation can make drainage worse.")],
            correctRepairID: "correct-trap-standpipe",
            timeLimitMinutes: 10,
            rewardCoins: 95,
            rewardXP: 75,
            learningTip: "Drain smells usually need trap and ventilation checks, not fragrance.",
            mentorHint: "Ask what happens immediately after the appliance pumps out.",
            safetyWarning: "Avoid contact with wastewater and clean the work area after testing.",
            isPremium: false,
            isFreeStarterJob: true,
            iconSystemName: "washer.fill"
        ),
        JobScenario(
            id: "beginner-outdoor-tap-frost",
            title: "Outdoor Tap Frost Leak",
            customerComplaint: "The outside tap sprays when opened after a cold night.",
            difficulty: .beginner,
            category: .leaks,
            requiredLevel: 2,
            requiredTools: ["adjustable-wrench", "bucket"],
            symptoms: ["Spray appears behind the wall plate.", "Pipe was not isolated during frost.", "Indoor stop valve works."],
            diagnosisQuestion: question("outdoor-frost-diagnosis", "What likely caused the leak?", [option("frost-damage", "Frost-damaged pipe or fitting", "Water expansion can split exposed parts."), option("blocked-sink", "Blocked kitchen sink", "This is unrelated to an outdoor tap spray."), option("low-cistern", "Low cistern level", "Cistern levels do not cause outdoor tap spray.")], "frost-damage", "A leak after freezing weather at an exposed tap strongly suggests frost damage."),
            repairOptions: [option("isolate-replace-protect", "Isolate, replace damaged part, add protection", "Repair the split section and advise winter isolation."), option("tighten-handle", "Tighten the tap handle", "The leak is behind the plate, not the handle."), option("leave-open", "Leave tap open permanently", "This wastes water and is unsafe.")],
            correctRepairID: "isolate-replace-protect",
            timeLimitMinutes: 10,
            rewardCoins: 100,
            rewardXP: 80,
            learningTip: "Outdoor taps need frost planning: isolation, drain-down, and insulation where required.",
            mentorHint: "Weather history is a diagnostic clue.",
            safetyWarning: "Confirm the internal isolation valve holds before working outside.",
            isPremium: false,
            isFreeStarterJob: true,
            iconSystemName: "snowflake"
        ),
        JobScenario(
            id: "beginner-customer-handover",
            title: "Customer Handover Check",
            customerComplaint: "The repair is complete, but the customer wants to know what changed.",
            difficulty: .beginner,
            category: .business,
            requiredLevel: 2,
            requiredTools: ["screwdriver-set"],
            symptoms: ["Customer asks for prevention tips.", "Area is dry after testing.", "Old part is available to show."],
            diagnosisQuestion: question("handover-diagnosis", "What is the best professional response?", [option("explain-test-clean", "Explain, test, and clean up", "A clear handover builds trust."), option("leave-fast", "Leave quickly", "Skipping handover hurts reputation."), option("promise-never-fails", "Promise it will never fail", "Avoid unsafe or unrealistic claims.")], "explain-test-clean", "Good handover includes what was found, what was fixed, and what the customer should watch for."),
            repairOptions: [option("show-repair-record", "Show repair and document advice", "Demonstrate the fix, leave practical advice, and record warnings."), option("upsell-random", "Upsell unrelated work", "Recommendations should match evidence."), option("avoid-questions", "Avoid questions", "Customers need clear, calm explanations.")],
            correctRepairID: "show-repair-record",
            timeLimitMinutes: 6,
            rewardCoins: 60,
            rewardXP: 65,
            learningTip: "Customer communication is part of the job. A clean, honest handover protects reputation.",
            mentorHint: "A customer should know what you changed and what to monitor.",
            safetyWarning: "Do not make guarantees or safety claims beyond the completed training scenario.",
            isPremium: false,
            isFreeStarterJob: true,
            iconSystemName: "checkmark.seal.fill"
        ),
        JobScenario(id: "intermediate-blocked-kitchen-sink", title: "Blocked Kitchen Sink", customerComplaint: "The kitchen sink is full of greasy water and the dishwasher backs up.", difficulty: .intermediate, category: .drainage, requiredLevel: 3, requiredTools: ["plunger", "bucket", "drain-auger"], symptoms: ["Both sink and dishwasher branch are affected.", "Trap is greasy.", "Plunging gives only brief relief."], diagnosisQuestion: question("kitchen-block-diagnosis", "Where is the blockage most likely?", [option("waste-branch", "Waste branch after the trap", "Multiple connected outlets point downstream of the trap."), option("incoming-main", "Incoming cold main", "Incoming water does not affect drainage."), option("tap-cartridge", "Tap cartridge", "The tap is not causing backup.")], "waste-branch", "Connected fixtures backing up suggests the restriction is past their shared connection."), repairOptions: [option("clear-branch-test", "Clear branch and flow test", "Remove trap debris, auger the branch, then test both outlets."), option("chemical-blast", "Pour stronger chemicals", "This skips mechanical diagnosis and creates hazards."), option("replace-dishwasher", "Replace dishwasher", "The shared drain route is the symptom source.")], correctRepairID: "clear-branch-test", timeLimitMinutes: 14, rewardCoins: 150, rewardXP: 110, learningTip: "When two appliances share a backup, think shared pipework.", mentorHint: "Map the branch connections before choosing a tool.", safetyWarning: "Use eye protection and avoid unknown chemical residues.", isPremium: false, isFreeStarterJob: false, iconSystemName: "sink.fill"),
        JobScenario(id: "intermediate-water-hammer", title: "Noisy Pipes: Water Hammer", customerComplaint: "Pipes bang loudly when the washing machine stops filling.", difficulty: .intermediate, category: .fixtures, requiredLevel: 4, requiredTools: ["pressure-gauge", "screwdriver-set"], symptoms: ["Bang occurs at valve closure.", "Pipes move in a cupboard.", "Static pressure reads high."], diagnosisQuestion: question("hammer-diagnosis", "What combination best explains the fault?", [option("high-pressure-loose-pipes", "High pressure and loose pipework", "Fast valve closure can shock unsecured pipework."), option("blocked-trap", "Blocked trap", "Drainage does not cause supply pipe bang."), option("low-boiler-pressure", "Low boiler pressure", "The symptom is on cold fill closure.")], "high-pressure-loose-pipes", "A fast-closing appliance valve plus pipe movement and high pressure points to water hammer."), repairOptions: [option("secure-check-pressure-arrestor", "Secure pipework and control pressure", "Clip accessible pipework, verify pressure, and consider an approved arrestor."), option("ignore-noise", "Ignore the noise", "Repeated hammer can damage fittings."), option("open-drain", "Open a drain trap", "The issue is supply-side shock.")], correctRepairID: "secure-check-pressure-arrestor", timeLimitMinutes: 18, rewardCoins: 190, rewardXP: 130, learningTip: "Water hammer diagnosis needs symptom reproduction, pressure measurement, and pipe support checks.", mentorHint: "The noise timing tells you it is linked to valve closure.", safetyWarning: "Pressure controls must be suitable for local regulations and manufacturer limits.", isPremium: false, isFreeStarterJob: false, iconSystemName: "waveform.path.ecg"),
        JobScenario(id: "heating-boiler-pressure-low", title: "Boiler Pressure Issue", customerComplaint: "The boiler pressure drops every few days and the heating stops.", difficulty: .heating, category: .heating, requiredLevel: 6, requiredTools: ["pressure-gauge", "radiator-key"], symptoms: ["Pressure falls after topping up.", "One radiator valve shows staining.", "No visible boiler leak."], diagnosisQuestion: question("boiler-pressure-diagnosis", "What should you investigate before repeatedly topping up?", [option("system-leak", "Possible system leak", "Recurring pressure loss usually has a cause."), option("clean-showerhead", "Clean shower head", "This does not affect sealed heating pressure."), option("turn-thermostat-up", "Turn thermostat up", "Controls do not explain pressure loss.")], "system-leak", "Repeated pressure loss should trigger a leak check before any top-up habit."), repairOptions: [option("find-leak-advise-qualified", "Find leak and advise qualified follow-up", "Check visible joints and radiators, document, and escalate regulated work."), option("top-up-daily", "Tell customer to top up daily", "This ignores the fault and can introduce system problems."), option("remove-pressure-gauge", "Remove the gauge", "The gauge is a safety indicator, not the problem.")], correctRepairID: "find-leak-advise-qualified", timeLimitMinutes: 20, rewardCoins: 230, rewardXP: 150, learningTip: "Low boiler pressure can be a symptom. Find why pressure is dropping before adjusting anything.", mentorHint: "Staining at a valve is stronger evidence than the number on its own.", safetyWarning: "Gas, combustion, and regulated boiler work must be handled by qualified professionals.", isPremium: true, isFreeStarterJob: false, iconSystemName: "flame.fill"),
        JobScenario(id: "emergency-burst-pipe", title: "Burst Pipe Emergency", customerComplaint: "Water is spraying through a ceiling after a pipe split upstairs.", difficulty: .emergency, category: .emergency, requiredLevel: 7, requiredTools: ["adjustable-wrench", "bucket", "wet-vac", "pipe-cutter"], symptoms: ["Active water spray.", "Customer cannot find isolation valve.", "Ceiling light is nearby."], diagnosisQuestion: question("burst-pipe-diagnosis", "What is the first priority?", [option("isolate-and-make-safe", "Isolate water and make area safe", "Stop the source and manage immediate hazards."), option("quote-full-bathroom", "Quote a full bathroom", "Emergency triage comes first."), option("cut-ceiling-now", "Cut ceiling immediately", "Do not cut before isolating and checking hazards.")], "isolate-and-make-safe", "Emergency work starts with isolation and safety before repair decisions."), repairOptions: [option("isolate-contain-temporary-repair", "Isolate, contain, and temporary repair", "Stop water, protect electrics by escalating, and make a safe temporary repair."), option("mop-only", "Mop without isolation", "Water will continue causing damage."), option("open-all-taps", "Open all taps only", "Draining may help after isolation but is not enough alone.")], correctRepairID: "isolate-contain-temporary-repair", timeLimitMinutes: 12, rewardCoins: 260, rewardXP: 170, learningTip: "Emergency profit comes after triage: isolate, make safe, contain, then repair.", mentorHint: "Active water plus nearby electrics means slow down and control hazards.", safetyWarning: "Keep away from electrical hazards and contact qualified help where required.", isPremium: true, isFreeStarterJob: false, iconSystemName: "exclamationmark.triangle.fill"),
        JobScenario(id: "advanced-cylinder-tundish", title: "Hot Water Tundish Drip", customerComplaint: "A clear fitting near the hot water cylinder keeps dripping.", difficulty: .advanced, category: .heating, requiredLevel: 8, requiredTools: ["pressure-gauge", "inspection-camera"], symptoms: ["Intermittent discharge visible at tundish.", "Cylinder cupboard is warm.", "Customer recently noticed higher water bills."], diagnosisQuestion: question("tundish-diagnosis", "How should this be treated?", [option("safety-discharge", "Safety discharge requiring qualified assessment", "A tundish drip may indicate pressure or temperature safety discharge."), option("normal-condensation", "Normal condensation", "Visible discharge from safety pipework should not be dismissed."), option("blocked-basin", "Blocked basin", "This is not a basin waste issue.")], "safety-discharge", "Safety discharge pipework needs proper qualified investigation."), repairOptions: [option("document-isolate-escalate", "Document and escalate appropriately", "Record symptoms, advise customer, and refer regulated checks."), option("cap-discharge", "Cap the discharge pipe", "Never block safety discharge routes."), option("ignore", "Ignore because it is clear water", "Clear water can still indicate a safety issue.")], correctRepairID: "document-isolate-escalate", timeLimitMinutes: 16, rewardCoins: 240, rewardXP: 150, learningTip: "Safety devices are not nuisances. Discharge pipework exists to show a fault safely.", mentorHint: "Never silence a safety warning without finding the cause.", safetyWarning: "Unvented cylinder work is regulated in many places and must be handled by qualified professionals.", isPremium: true, isFreeStarterJob: false, iconSystemName: "thermometer.sun.fill"),
        JobScenario(id: "advanced-bathroom-rough-in", title: "Bathroom Installation Rough-In", customerComplaint: "A renovation needs first-fix pipe routes checked before walls close.", difficulty: .advanced, category: .installation, requiredLevel: 8, requiredTools: ["pipe-cutter", "press-tool", "pipe-sizing-wheel"], symptoms: ["Long pipe runs planned.", "Multiple fixtures share one branch.", "Stud wall has limited support points."], diagnosisQuestion: question("rough-in-diagnosis", "What is the main planning risk?", [option("undersized-unsupported-runs", "Undersized or unsupported runs", "Poor sizing and support create future faults."), option("dirty-aerator", "Dirty aerator", "Fixtures are not installed yet."), option("cistern-overflow", "Cistern overflow", "This is a planning stage issue.")], "undersized-unsupported-runs", "First fix is the moment to check sizing, support, and service access."), repairOptions: [option("revise-route-support-size", "Revise route, supports, and sizing", "Confirm demand, use suitable fittings, and leave service access."), option("close-walls-fast", "Close walls quickly", "Hidden poor work becomes expensive rework."), option("use-random-fittings", "Use spare random fittings", "Compatibility matters.")], correctRepairID: "revise-route-support-size", timeLimitMinutes: 24, rewardCoins: 310, rewardXP: 190, learningTip: "Good installation work is planned before the pipe is hidden.", mentorHint: "Ask how future you will service this route.", safetyWarning: "Follow local codes, product instructions, and required inspection stages.", isPremium: true, isFreeStarterJob: false, iconSystemName: "hammer.fill"),
        JobScenario(id: "advanced-incorrect-pipe-sizing", title: "Incorrect Pipe Sizing Issue", customerComplaint: "A new utility room loses flow when two outlets run together.", difficulty: .advanced, category: .installation, requiredLevel: 9, requiredTools: ["pressure-gauge", "pipe-sizing-wheel"], symptoms: ["Static pressure is acceptable.", "Flow drops under simultaneous demand.", "Long small-bore run feeds both outlets."], diagnosisQuestion: question("sizing-diagnosis", "What does good static pressure but poor combined flow suggest?", [option("pipe-sizing-flow-loss", "Pipe sizing or flow restriction", "Demand exceeds what the route can deliver."), option("radiator-air", "Radiator air", "This is not a heating emitter symptom."), option("trap-smell", "Trap smell", "Waste traps do not reduce supply flow.")], "pipe-sizing-flow-loss", "Pressure at rest can look fine even when pipework cannot deliver flow under demand."), repairOptions: [option("calculate-upsize-route", "Calculate demand and upsize route", "Use measured evidence to revise pipe sizing or route restrictions."), option("raise-pressure-only", "Raise pressure only", "Pressure increase may breach limits and miss friction loss."), option("replace-washer", "Replace tap washer", "Multiple outlets are affected under demand.")], correctRepairID: "calculate-upsize-route", timeLimitMinutes: 22, rewardCoins: 300, rewardXP: 185, learningTip: "Static pressure is not the same as usable flow under demand.", mentorHint: "Test with one outlet, then two outlets, and compare the drop.", safetyWarning: "Do not exceed appliance or regulatory pressure limits to mask poor sizing.", isPremium: true, isFreeStarterJob: false, iconSystemName: "circle.hexagongrid.fill"),
        JobScenario(id: "commercial-flush-valve", title: "Commercial Flush Valve Fault", customerComplaint: "A washroom flush valve runs constantly between busy periods.", difficulty: .commercial, category: .commercial, requiredLevel: 10, requiredTools: ["screwdriver-set", "pressure-gauge"], symptoms: ["Continuous run after flush.", "High site pressure recorded.", "Several valves are the same model."], diagnosisQuestion: question("flush-valve-diagnosis", "What is the best next diagnostic step?", [option("check-pressure-and-diaphragm", "Check pressure and diaphragm", "Commercial flush valves depend on correct pressure and internal seals."), option("replace-toilet-seat", "Replace toilet seat", "The seat does not control flush flow."), option("clear-basin-trap", "Clear basin trap", "The issue is a flush valve, not a basin waste.")], "check-pressure-and-diaphragm", "The pressure reading and constant run point to valve internals or operating pressure."), repairOptions: [option("service-valve-document", "Service valve and document site pattern", "Fit approved service parts, retest, and note if more valves need planned work."), option("turn-off-washroom", "Turn off washroom indefinitely", "This avoids repair and disrupts the site."), option("force-handle", "Force the handle harder", "This can damage the mechanism.")], correctRepairID: "service-valve-document", timeLimitMinutes: 25, rewardCoins: 360, rewardXP: 210, learningTip: "Commercial maintenance rewards repeatable diagnosis and documentation.", mentorHint: "When several fixtures share a model, one repair can reveal a site-wide pattern.", safetyWarning: "Follow site access rules and protect public washroom areas during testing.", isPremium: true, isFreeStarterJob: false, iconSystemName: "building.2.fill"),
        JobScenario(id: "heating-radiator-not-heating", title: "Radiator Not Heating Downstairs", customerComplaint: "One downstairs radiator stays cold while others heat normally.", difficulty: .heating, category: .heating, requiredLevel: 9, requiredTools: ["radiator-key", "thermal-camera"], symptoms: ["Both valves appear open.", "Pipe to valve is warm on one side only.", "Customer recently decorated."], diagnosisQuestion: question("radiator-not-heating-diagnosis", "What should you check first?", [option("valve-stuck-or-closed", "Valve stuck or closed", "A local valve issue can isolate one radiator."), option("main-drain-blocked", "Main drain blocked", "Other heating emitters are working."), option("replace-boiler", "Replace boiler", "One cold radiator is not enough evidence.")], "valve-stuck-or-closed", "A single radiator fault with normal system operation points local first."), repairOptions: [option("check-valves-balance", "Check valves and balance flow", "Verify valve operation, bleed if needed, and rebalance where appropriate."), option("drain-full-system-now", "Drain full system immediately", "Start with less invasive local checks."), option("paint-over-valve", "Paint over valve", "That may worsen stuck parts.")], correctRepairID: "check-valves-balance", timeLimitMinutes: 20, rewardCoins: 250, rewardXP: 160, learningTip: "One cold radiator usually deserves local valve, air, and balancing checks before major work.", mentorHint: "Recent decorating can leave valves closed, painted, or disturbed.", safetyWarning: "Heating systems can be hot and pressurized; work within training limits.", isPremium: true, isFreeStarterJob: false, iconSystemName: "flame.circle.fill"),
        JobScenario(id: "heating-pump-cavitation", title: "Noisy Heating Pump", customerComplaint: "The central heating pump sounds like gravel when it starts.", difficulty: .heating, category: .heating, requiredLevel: 11, requiredTools: ["pressure-gauge", "thermal-camera"], symptoms: ["Noise at pump body.", "System pressure is low.", "Some radiators gurgle."], diagnosisQuestion: question("pump-cavitation-diagnosis", "What does this pattern suggest?", [option("air-or-low-pressure", "Air or low system pressure", "Gurgling plus low pressure can cause pump noise."), option("blocked-basin", "Blocked basin", "Drainage is unrelated."), option("wrong-toilet-seat", "Wrong toilet seat", "This is not a bathroom fixture issue.")], "air-or-low-pressure", "Low pressure and air symptoms can create noisy circulation."), repairOptions: [option("safe-pressure-air-check", "Check pressure and air safely", "Find cause, restore safe pressure if appropriate, and bleed according to guidance."), option("hit-pump", "Hit the pump casing", "Impact can damage equipment."), option("max-speed", "Set pump to maximum", "More speed can worsen noise without fixing air.")], correctRepairID: "safe-pressure-air-check", timeLimitMinutes: 22, rewardCoins: 280, rewardXP: 180, learningTip: "Noisy pumps often need system condition checks, not just pump speed changes.", mentorHint: "Listen to where the sound starts and compare it with pressure readings.", safetyWarning: "Escalate electrical, boiler, or regulated heating work to qualified professionals.", isPremium: true, isFreeStarterJob: false, iconSystemName: "fanblades.fill"),
        JobScenario(id: "advanced-backflow-risk", title: "Backflow Risk on Hose Bib", customerComplaint: "A garden hose is left in a paddling pool connected to an outside tap.", difficulty: .advanced, category: .fixtures, requiredLevel: 10, requiredTools: ["adjustable-wrench", "pressure-gauge"], symptoms: ["Hose end submerged.", "No backflow device visible.", "Children use the pool."], diagnosisQuestion: question("backflow-diagnosis", "What is the key hazard?", [option("back-siphonage", "Back-siphonage contamination", "Submerged hoses can contaminate potable water."), option("hot-water-delay", "Hot water delay", "The issue is water quality protection."), option("radiator-sludge", "Radiator sludge", "This is not a heating circuit.")], "back-siphonage", "A submerged hose without protection can allow contaminated water to be drawn back."), repairOptions: [option("fit-approved-protection", "Fit approved backflow protection", "Remove the hazard and use suitable protection per local rules."), option("ignore-because-outside", "Ignore because it is outside", "Outside taps still connect to potable supplies."), option("raise-temperature", "Raise water temperature", "Temperature does not solve backflow risk.")], correctRepairID: "fit-approved-protection", timeLimitMinutes: 18, rewardCoins: 270, rewardXP: 175, learningTip: "Water quality protection is plumbing, not paperwork.", mentorHint: "Ask what could flow backward if pressure changed.", safetyWarning: "Backflow rules vary by location; follow local regulations.", isPremium: true, isFreeStarterJob: false, iconSystemName: "shield.fill"),
        JobScenario(id: "advanced-concealed-leak", title: "Concealed Leak Tracing", customerComplaint: "A downstairs ceiling stain keeps returning after rain is ruled out.", difficulty: .advanced, category: .leaks, requiredLevel: 11, requiredTools: ["inspection-camera", "thermal-camera", "pressure-gauge"], symptoms: ["Stain grows after bathroom use.", "Moisture meter peaks below shower wall.", "No leak visible at basin or WC."], diagnosisQuestion: question("concealed-leak-diagnosis", "What evidence is strongest?", [option("use-related-moisture", "Moisture linked to shower use", "Timing and location point to the shower area."), option("random-ceiling-paint", "Paint color", "Paint color is not diagnostic."), option("street-pressure", "Street pressure only", "Pressure alone does not locate a use-related leak.")], "use-related-moisture", "A recurring stain after shower use points toward shower waste, seal, or supply routes."), repairOptions: [option("non-invasive-trace-test", "Trace and test non-invasively first", "Use observation, moisture patterns, and controlled testing before opening surfaces."), option("rip-out-wall", "Rip out wall immediately", "Destructive work should follow evidence."), option("paint-ceiling", "Paint over the stain", "The source remains active.")], correctRepairID: "non-invasive-trace-test", timeLimitMinutes: 28, rewardCoins: 390, rewardXP: 230, learningTip: "Good leak tracing reduces damage by proving the route before opening surfaces.", mentorHint: "Change one water source at a time and watch the stain area.", safetyWarning: "Check for electrical hazards and structural damage before invasive work.", isPremium: true, isFreeStarterJob: false, iconSystemName: "camera.macro"),
        JobScenario(id: "commercial-maintenance-contract", title: "Commercial Maintenance Contract", customerComplaint: "A cafe wants a monthly check after repeated sink and tap failures.", difficulty: .commercial, category: .commercial, requiredLevel: 12, requiredTools: ["drain-auger", "pressure-gauge", "screwdriver-set"], symptoms: ["High-use kitchen sink.", "Staff report slow drains at closing.", "Tap cartridges fail often."], diagnosisQuestion: question("contract-diagnosis", "What should the maintenance plan include?", [option("planned-inspection-log", "Planned inspection and log", "Patterns matter in high-use sites."), option("wait-for-breakdowns", "Wait for breakdowns", "Reactive-only work is costly."), option("replace-everything-now", "Replace everything immediately", "Use evidence before major spend.")], "planned-inspection-log", "A contract should record checks, recurring faults, and planned maintenance."), repairOptions: [option("service-schedule-risk-notes", "Create service schedule and risk notes", "Plan drain cleaning, pressure checks, spares, and hygiene-safe handover."), option("cash-only-no-record", "Take cash with no record", "Commercial clients need documentation."), option("ignore-staff-feedback", "Ignore staff feedback", "Operators know the pattern of use.")], correctRepairID: "service-schedule-risk-notes", timeLimitMinutes: 30, rewardCoins: 420, rewardXP: 245, learningTip: "Commercial value comes from preventing downtime, not just fixing today's fault.", mentorHint: "Turn repeat callouts into a maintenance pattern.", safetyWarning: "Follow food business hygiene and site safety requirements.", isPremium: true, isFreeStarterJob: false, iconSystemName: "calendar.badge.clock"),
        JobScenario(id: "heating-condensate-blockage", title: "Boiler Condensate Blockage", customerComplaint: "The boiler stops on cold mornings and a small plastic pipe outside is frozen.", difficulty: .heating, category: .heating, requiredLevel: 12, requiredTools: ["bucket", "thermal-camera"], symptoms: ["Fault follows freezing weather.", "External condensate pipe is exposed.", "Boiler shows a condensate-related lockout code."], diagnosisQuestion: question("condensate-diagnosis", "What is the likely issue?", [option("frozen-condensate", "Frozen or blocked condensate pipe", "Cold weather and exposed plastic pipe are key clues."), option("blocked-toilet", "Blocked toilet", "This is not a WC symptom."), option("high-shower-flow", "High shower flow", "Flow rate does not explain lockout code.")], "frozen-condensate", "A frozen condensate route can stop suitable boilers and needs safe thawing and prevention."), repairOptions: [option("safe-thaw-insulate-advise", "Safely thaw, insulate, and advise", "Use manufacturer guidance and prevent recurrence with routing or insulation advice."), option("use-boiling-water", "Use boiling water", "This can damage pipework and injure people."), option("block-pipe", "Block the pipe to stop dripping", "Condensate must discharge safely.")], correctRepairID: "safe-thaw-insulate-advise", timeLimitMinutes: 18, rewardCoins: 290, rewardXP: 185, learningTip: "Weather-related faults need both a fix and prevention advice.", mentorHint: "The outside pipe and timing are stronger clues than room thermostat settings.", safetyWarning: "Do not open or adjust gas appliance internals unless qualified.", isPremium: true, isFreeStarterJob: false, iconSystemName: "snowflake.circle.fill"),
        JobScenario(id: "business-quote-dispute", title: "Quote Dispute Follow-Up", customerComplaint: "A customer says the final invoice is higher than expected after extra parts were needed.", difficulty: .commercial, category: .business, requiredLevel: 13, requiredTools: ["screwdriver-set"], symptoms: ["Original quote missed access issues.", "Extra parts were approved verbally.", "Customer is unhappy with communication."], diagnosisQuestion: question("quote-dispute-diagnosis", "What caused the business fault?", [option("unclear-change-control", "Unclear change control", "Extra work needs clear approval and records."), option("wrong-plunger", "Wrong plunger", "This is a communication and quoting issue."), option("low-boiler-pressure", "Low boiler pressure", "No heating symptom is described.")], "unclear-change-control", "The repair may be valid, but approval and documentation were weak."), repairOptions: [option("review-records-offer-clear-resolution", "Review records and offer clear resolution", "Explain the change, improve documentation, and protect reputation."), option("blame-customer", "Blame the customer", "That escalates the dispute."), option("delete-invoice", "Delete the invoice", "Records must be accurate and lawful.")], correctRepairID: "review-records-offer-clear-resolution", timeLimitMinutes: 16, rewardCoins: 320, rewardXP: 210, learningTip: "A plumbing business wins trust with clear scope, written changes, and calm follow-up.", mentorHint: "The technical fix is done; the fault is the change process.", safetyWarning: "Business simulations are educational and not legal advice.", isPremium: true, isFreeStarterJob: false, iconSystemName: "doc.text.fill")
    ]

    private static func option(_ id: String, _ title: String, _ detail: String) -> DecisionOption {
        DecisionOption(id: id, title: title, detail: detail)
    }

    private static func question(_ id: String, _ prompt: String, _ options: [DecisionOption], _ correctOptionID: String, _ explanation: String) -> DiagnosisQuestion {
        DiagnosisQuestion(id: id, prompt: prompt, options: options, correctOptionID: correctOptionID, explanation: explanation)
    }
}

struct AppCopy {
    let appName = "PipeBoss AI"
    let proName = "PipeBoss Pro"
    let reviewProductList = "PipeBoss Pro Monthly, PipeBoss Pro Yearly, Emergency Jobs Pack, Advanced Tool Pack, City Expansion Pack, and Business Owner Mode."
    let educationalDisclaimer = "PipeBoss AI is for educational training and simulation only. Always follow local regulations and consult a qualified professional for real-world plumbing work."
    let privacySummary = "PipeBoss AI stores MVP progress on this device and does not collect unnecessary personal data."
    let termsURL = "https://github.com/lanray07/PipeBoss-AI/blob/main/TERMS.md"
    let privacyURL = "https://github.com/lanray07/PipeBoss-AI/blob/main/PRIVACY.md"
    let ok = "OK"

    let tabs = TabCopy()
    let onboarding = OnboardingCopy()
    let dashboard = DashboardCopy()
    let jobs = JobCopy()
    let simulation = SimulationCopy()
    let inventory = InventoryCopy()
    let business = BusinessCopy()
    let learning = LearningCopy()
    let leaderboard = LeaderboardCopy()
    let paywall = PaywallCopy()
    let settings = SettingsCopy()

    func difficultyTitle(_ difficulty: JobDifficulty) -> String {
        switch difficulty {
        case .beginner: return "Beginner"
        case .intermediate: return "Intermediate"
        case .advanced: return "Advanced"
        case .heating: return "Heating"
        case .commercial: return "Commercial"
        case .emergency: return "Emergency"
        }
    }

    func categoryTitle(_ category: JobCategory) -> String {
        switch category {
        case .leaks: return "Leaks"
        case .drainage: return "Drainage"
        case .fixtures: return "Fixtures"
        case .heating: return "Heating"
        case .installation: return "Installation"
        case .commercial: return "Commercial"
        case .emergency: return "Emergency"
        case .business: return "Business"
        }
    }

    func toolCategoryTitle(_ category: ToolCategory) -> String {
        switch category {
        case .handTools: return "Hand Tools"
        case .drainage: return "Drainage"
        case .testing: return "Testing"
        case .heating: return "Heating"
        case .specialist: return "Specialist"
        }
    }

    func upgradeCategoryTitle(_ category: UpgradeCategory) -> String {
        switch category {
        case .vehicle: return "Vehicle"
        case .workshop: return "Workshop"
        case .training: return "Training"
        case .marketing: return "Marketing"
        case .business: return "Business"
        }
    }
}

struct TabCopy {
    let home = "Home"
    let jobs = "Jobs"
    let tools = "Tools"
    let learn = "Learn"
    let business = "Business"
}

struct OnboardingCopy {
    let namePlaceholder = "Apprentice name"
    let nextButton = "Next"
    let startButton = "Start career"
}

struct DashboardCopy {
    let title = "Workshop Dashboard"
    let subtitle = "Choose the next job, sharpen your diagnosis, and keep the business moving."
    let xp = "XP"
    let coins = "Coins"
    let energy = "Energy"
    let reputation = "Reputation"
    let careerProgress = "Career Progress"
    let nextJob = "Next recommended job"
    let startJob = "Open job board"
    let proPrompt = "Subscriptions and expansion packs"
    let proButton = "Open PipeBoss Store"
    let leaderboard = "Leaderboard"
    let settings = "Settings and privacy"
}

struct JobCopy {
    let title = "Job Board"
    let subtitle = "Unlocked work is based on level, tools, energy, and premium packs."
    let allFilter = "All"
    let locked = "Locked"
    let premium = "Pro"
    let missingTools = "Missing tools"
    let noEnergy = "No energy"
    let time = "Time"
    let reward = "Reward"
    let requiredTools = "Required tools"
    let start = "Start"
    let watchAd = "Watch optional ad"
    let refillEnergy = "Refill energy"
}

struct SimulationCopy {
    let customerBrief = "Customer brief"
    let symptoms = "Symptoms"
    let requiredTools = "Required tools"
    let safety = "Safety warning"
    let masterTip = "Master Plumber Tip"
    let mentorHint = "Mentor hint"
    let unlockHint = "Unlock hint"
    let selectTools = "Select tools"
    let continueDiagnosis = "Diagnose fault"
    let diagnosis = "Diagnosis challenge"
    let confirmDiagnosis = "Confirm diagnosis"
    let repair = "Repair decision"
    let confirmRepair = "Complete repair"
    let result = "Job result"
    let finish = "Back to dashboard"
    let correct = "Correct"
    let needsRework = "Needs rework"
    let timer = "Job timer"
    let inspect = "Inspect issue"
}

struct InventoryCopy {
    let title = "Tool Inventory"
    let subtitle = "Upgrade the kit as jobs become more technical."
    let owned = "Owned"
    let available = "Available"
    let buy = "Buy"
    let lockedLevel = "Level locked"
    let starter = "Starter kit"
}

struct BusinessCopy {
    let title = "Business Upgrades"
    let subtitle = "Spend coins on systems that improve speed, trust, and training depth."
    let upgrades = "Upgrades"
    let packs = "One-time packs"
    let rewardedAds = "Optional rewarded ads"
    let coinsReward = "Earn extra coins"
    let energyReward = "Refill job energy"
    let hintReward = "Unlock one hint"
    let buy = "Buy upgrade"
    let owned = "Owned"
}

struct LearningCopy {
    let title = "Learning Cards"
    let subtitle = "Practical notes unlock as you level up and complete jobs."
    let locked = "Locked"
    let premium = "Pro card"
    let unlocked = "Unlocked"
}

struct LeaderboardCopy {
    let title = "Leaderboard"
    let subtitle = "Local sample rankings for MVP screenshots. Cloud competition can be added later."
    let rank = "Rank"
    let reputation = "Rating"
}

struct PaywallCopy {
    let title = "PipeBoss Store"
    let subtitle = "Review PipeBoss Pro subscriptions and one-time expansion packs."
    let monthly = "Monthly"
    let yearly = "Yearly"
    let subscribe = "Subscribe"
    let restore = "Restore purchases"
    let manage = "Manage subscription"
    let terms = "Terms of Use"
    let privacy = "Privacy Policy"
    let close = "Close"
    let subscriptions = "PipeBoss Pro subscriptions"
    let oneTimePacks = "One-time expansion packs"
    let reviewHint = "App Review: all subscriptions and one-time purchases are available here from Home > Open PipeBoss Store. Packs are also listed on the Business tab."
    let termsSummary = "Subscriptions renew automatically unless cancelled at least 24 hours before the end of the current period. Pricing is shown by the App Store before purchase. Manage or cancel in your Apple ID subscription settings."
    let optionalAdsSummary = "Rewarded ads are optional for free users and never interrupt gameplay or learning."
    let proAdsSummary = "PipeBoss Pro removes ads and keeps jobs unlimited."
    let storeUnavailableMessage = "App Store products are currently unavailable. Check the network or sandbox account and try again."
    let loadingProducts = "Loading App Store products..."
    let productUnavailable = "This product is not available from the App Store yet."
    let retryStore = "Retry App Store products"
    let pendingPurchaseMessage = "Purchase is pending approval."
    let restoreFailedMessage = "Restore did not complete. Try again from the App Store account used to subscribe."
    let manageUnavailableMessage = "Subscription management is unavailable in this environment."
}

struct SettingsCopy {
    let title = "Settings and Privacy"
    let subtitle = "Offline-first training with clear safety boundaries."
    let privacy = "Privacy-friendly MVP"
    let disclaimer = "Training disclaimer"
    let legal = "Legal"
    let reset = "Reset progress"
    let resetConfirm = "Reset saved progress?"
    let resetConfirmMessage = "This clears local XP, coins, tools, completed jobs, and onboarding state on this device."
    let resetNow = "Reset"
    let cancel = "Cancel"
    let appVersion = "Version 1.0 MVP"
    let localProgress = "Local progress uses UserDefaults for the MVP."
}
