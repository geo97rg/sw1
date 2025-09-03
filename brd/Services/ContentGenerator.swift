import Foundation

class ContentGenerator {
    static let shared = ContentGenerator()
    
    private init() {}
    
    // MARK: - Content Arrays
    private let characters = [
        "a torch-bearing chicken",
        "a shy robot",
        "an introvert pirate",
        "a singing skeleton",
        "a philosophical goblin",
        "a time-traveling baker",
        "a nervous dragon",
        "a vegetarian vampire",
        "a forgetful wizard",
        "an ambitious mushroom",
        "a diplomatic orc",
        "a melancholic phoenix",
        "a curious gargoyle",
        "an optimistic ghost",
        "a rebellious knight",
        "a scholarly barbarian",
        "a peaceful necromancer",
        "a clumsy assassin",
        "a romantic zombie",
        "a methodical chaos demon",
        "a cheerful banshee",
        "a minimalist treasure hunter",
        "a vegan werewolf",
        "an anxious oracle",
        "a perfectionistic imp"
    ]
    
    private let settings = [
        "an ember-lit dungeon",
        "a rainy desert",
        "a moon library",
        "a floating tavern",
        "an underwater volcano",
        "a crystalline forest",
        "a clockwork castle",
        "a living maze",
        "a frozen lighthouse",
        "a singing swamp",
        "an inverted tower",
        "a mirror dimension",
        "a cloud prison",
        "a bone garden",
        "a magnetic mountain",
        "a dreamscape battlefield",
        "a pocket universe",
        "an endless staircase",
        "a memory palace",
        "a shadow market",
        "a time-locked village",
        "a glass ocean",
        "a gravity well",
        "an echo chamber",
        "a probability storm"
    ]
    
    private let goals = [
        "to relight the last torch",
        "to unite rivals",
        "to decode a song",
        "to break an ancient curse",
        "to find the missing piece",
        "to restore balance",
        "to wake the sleeping",
        "to silence the echoes",
        "to mend what was broken",
        "to remember the forgotten",
        "to prove their worth",
        "to escape the loop",
        "to solve the riddle",
        "to calm the storm",
        "to bridge two worlds",
        "to steal the unstealable",
        "to tame the wild",
        "to reveal the truth",
        "to prevent the prophecy",
        "to win an impossible game",
        "to grow the ungrowable",
        "to catch the uncatchable",
        "to heal the unhealable",
        "to build the unbuildable",
        "to find home"
    ]
    
    private let twists = [
        "under flickering torchlight",
        "with only echoes as clues",
        "no electricity allowed",
        "while time runs backward",
        "everything is upside down",
        "magic doesn't work here",
        "everyone speaks in riddles",
        "gravity is optional",
        "memories fade every hour",
        "shadows have their own agenda",
        "music controls reality",
        "emotions are visible",
        "lies become truth",
        "silence is deadly",
        "colors have meaning",
        "dreams are currency",
        "names have power",
        "mirrors show the future",
        "touch reveals secrets",
        "laughter is forbidden",
        "questions cost memories",
        "walking changes the past",
        "breathing controls time",
        "thoughts become real",
        "darkness brings wisdom"
    ]
    
    // MARK: - Generation Methods
    func generateCombo(categories: [Category]) -> Combo {
        var items: [ComboItem] = []
        
        for category in categories {
            if let value = generateValue(for: category) {
                items.append(ComboItem(category: category, value: value))
            }
        }
        
        return Combo(items: items)
    }
    
    func generateValue(for category: Category) -> String? {
        switch category {
        case .character:
            return characters.randomElement()
        case .setting:
            return settings.randomElement()
        case .goal:
            return goals.randomElement()
        case .twist:
            return twists.randomElement()
        }
    }
    
    func generateDailyCombo(for date: Date) -> Combo {
        // Create deterministic seed from date
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let seed = (components.year ?? 0) * 10000 + (components.month ?? 0) * 100 + (components.day ?? 0)
        
        // Use seeded random generator
        var generator = SeededRandomGenerator(seed: seed)
        
        var items: [ComboItem] = []
        
        // Always include all categories for daily
        for category in Category.allCases {
            let value: String
            switch category {
            case .character:
                value = characters.randomElement(using: &generator) ?? characters[0]
            case .setting:
                value = settings.randomElement(using: &generator) ?? settings[0]
            case .goal:
                value = goals.randomElement(using: &generator) ?? goals[0]
            case .twist:
                value = twists.randomElement(using: &generator) ?? twists[0]
            }
            items.append(ComboItem(category: category, value: value))
        }
        
        return Combo(items: items, createdAt: date)
    }
}

// MARK: - Seeded Random Generator
struct SeededRandomGenerator: RandomNumberGenerator {
    private var seed: UInt64
    
    init(seed: Int) {
        self.seed = UInt64(abs(seed))
    }
    
    mutating func next() -> UInt64 {
        seed = (seed &* 1664525 &+ 1013904223) & 0xffffffff
        return seed
    }
}