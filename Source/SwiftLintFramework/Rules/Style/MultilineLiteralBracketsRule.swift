import Foundation
import SourceKittenFramework

public struct MultilineLiteralBracketsRule: ASTRule, OptInRule, ConfigurationProviderRule, AutomaticTestableRule {
    public var configuration = SeverityConfiguration(.warning)

    public init() {}

    public static let description = RuleDescription(
        identifier: "multiline_literal_brackets",
        name: "Multiline Literal Brackets",
        description: "Multiline literals should have their surrounding brackets in a new line.",
        kind: .style,
        nonTriggeringExamples: [
            """
            let trio = ["harry", "ronald", "hermione"]
            let houseCup = ["gryffinder": 460, "hufflepuff": 370, "ravenclaw": 410, "slytherin": 450]
            """,
            """
            let trio = [
                "harry",
                "ronald",
                "hermione"
            ]
            let houseCup = [
                "gryffinder": 460,
                "hufflepuff": 370,
                "ravenclaw": 410,
                "slytherin": 450
            ]
            """,
            """
            let trio = [
                "harry", "ronald", "hermione"
            ]
            let houseCup = [
                "gryffinder": 460, "hufflepuff": 370,
                "ravenclaw": 410, "slytherin": 450
            ]
            """,
            """
                _ = [
                    1,
                    2,
                    3,
                    4,
                    5, 6,
                    7, 8, 9
                ]
            """
        ],
        triggeringExamples: [
            """
            let trio = [↓"harry",
                        "ronald",
                        "hermione"
            ]
            """,
            """
            let houseCup = [↓"gryffinder": 460, "hufflepuff": 370,
                            "ravenclaw": 410, "slytherin": 450
            ]
            """,
            """
            let trio = [
                "harry",
                "ronald",
                "hermione"↓]
            """,
            """
            let houseCup = [
                "gryffinder": 460, "hufflepuff": 370,
                "ravenclaw": 410, "slytherin": 450↓]
            """,
            """
            class Hogwarts {
                let houseCup = [
                    "gryffinder": 460, "hufflepuff": 370,
                    "ravenclaw": 410, "slytherin": 450↓]
            }
            """,
            """
                _ = [
                    1,
                    2,
                    3,
                    4,
                    5, 6,
                    7, 8, 9↓]
            """,
            """
                _ = [↓1, 2, 3,
                     4, 5, 6,
                     7, 8, 9
                ]
            """
        ]
    )

    public func validate(file: SwiftLintFile,
                         kind: SwiftExpressionKind,
                         dictionary: SourceKittenDictionary) -> [StyleViolation] {
        guard
            [.array, .dictionary].contains(kind),
            let bodyByteRange = dictionary.bodyByteRange,
            let body = file.stringView.substringWithByteRange(bodyByteRange)
        else {
            return []
        }

        let isMultiline = body.contains("\n")
        guard isMultiline else {
            return []
        }

        let expectedBodyBeginRegex = regex("\\A[ \\t]*\\n")
        let expectedBodyEndRegex = regex("\\n[ \\t]*\\z")

        var violatingByteOffsets = [ByteCount]()
        if expectedBodyBeginRegex.firstMatch(in: body, options: [], range: body.fullNSRange) == nil {
            violatingByteOffsets.append(bodyByteRange.location)
        }

        if expectedBodyEndRegex.firstMatch(in: body, options: [], range: body.fullNSRange) == nil {
            violatingByteOffsets.append(bodyByteRange.upperBound)
        }

        return violatingByteOffsets.map { byteOffset in
            StyleViolation(
                ruleDescription: type(of: self).description, severity: configuration.severity,
                location: Location(file: file, byteOffset: byteOffset)
            )
        }
    }
}
