import SwiftUI

struct InvestmentCard: View {
    let investment: Investment
    @State private var viewStartTime = Date()
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    var body: some View {
        ZStack {
            // Noise texture overlay
            NoiseTextureView()
                .opacity(0.03)
                .allowsHitTesting(false)
            
            ScrollView {
                VStack(alignment: .leading, spacing: AppConstants.spacingLG) {
                    // Header (matching React mockup exactly)
                    VStack(alignment: .leading, spacing: AppConstants.spacingXS) {
                        if investment.type == .stock {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: AppConstants.spacingXS) {
                                    Text(investment.ticker ?? "N/A")
                                        .font(.custom(AppFonts.serifTitle, size: AppConstants.fontSizeCardTitle))
                                        .fontWeight(.semibold)
                                        .foregroundColor(AppColors.text)
                                        .tracking(AppConstants.trackingCardTitle)
                                    
                                    Text(investment.title)
                                        .font(.system(size: AppConstants.fontSizeCardSubtitle, weight: .regular))
                                        .foregroundColor(AppColors.textSecondary)
                                        .lineLimit(2)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    HStack(spacing: 8) {
                                        Text(investment.price ?? "N/A")
                                            .font(.system(size: AppConstants.fontSizePrice, weight: .medium))
                                            .foregroundColor(AppColors.text)
                                        
                                        if let change = investment.change, !change.isEmpty {
                                            Text(change)
                                                .font(.system(size: AppConstants.fontSizePriceChange, weight: .regular))
                                                .foregroundColor(change.hasPrefix("-") ? AppColors.red : AppColors.green)
                                        }
                                    }
                                    
                                    // Price disclaimer
                                    Text("Estimate for education only")
                                        .font(.system(size: 10))
                                        .foregroundColor(AppColors.textSecondary.opacity(0.6))
                                        .italic()
                                }
                            }
                        } else {
                            VStack(alignment: .leading, spacing: AppConstants.spacingXS) {
                                Text(investment.title)
                                    .font(.custom(AppFonts.serifTitle, size: 36))
                                    .fontWeight(.semibold)
                                    .foregroundColor(AppColors.text)
                                    .tracking(AppConstants.trackingHeader)
                                
                                HStack(spacing: AppConstants.spacingSM) {
                                    Text(investment.category ?? "")
                                        .font(.system(size: AppConstants.fontSizeCardSubtitle, weight: .regular))
                                        .foregroundColor(AppColors.textSecondary)
                                    
                                    Text("•")
                                        .foregroundColor(AppColors.textSecondary)
                                    
                                    Text(investment.investment ?? "")
                                        .font(.system(size: AppConstants.fontSizeCardSubtitle, weight: .regular))
                                        .foregroundColor(AppColors.textSecondary)
                                }
                            }
                        }
                    }
                    .padding(.bottom, AppConstants.spacingXS)
                    
                    // Divider
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.clear, AppColors.border, Color.clear]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 1)
                        .padding(.bottom, AppConstants.spacingLG)
                    
                    // Tagline (3px white left border, 16px padding after, 16px vertical padding)
                    HStack(spacing: 0) {
                        Rectangle()
                            .fill(AppColors.text)
                            .frame(width: 3)
                        
                        Text(investment.tagline)
                            .font(.system(size: AppConstants.fontSizeTagline, weight: .regular))
                            .foregroundColor(AppColors.text)
                            .lineSpacing(4) // Line height 1.4 = 24px for 17px font
                            .lineLimit(3)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.leading, AppConstants.spacingMD)
                            .padding(.vertical, AppConstants.spacingMD)
                    }
                    .background(AppColors.darkGray)
                    .cornerRadius(0)
                    
                    // Simple Explainer (section spacing: 24px)
                    VStack(alignment: .leading, spacing: AppConstants.spacingXS) {
                        Text("IN PLAIN ENGLISH")
                            .font(.system(size: AppConstants.fontSizeSectionHeader, weight: .bold))
                            .tracking(AppConstants.trackingSectionHeader)
                            .foregroundColor(AppColors.textSecondary)
                        
                        Text(investment.simpleExplainer)
                            .font(.system(size: AppConstants.fontSizeBody, weight: .regular))
                            .foregroundColor(AppColors.text)
                            .lineSpacing(6) // Line height 1.5 = 22.5px for 15px font
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    // What to Expect (padding: 16px, corner radius: 8px, border: 1px #333333, icon: 16px, icon-to-text: 12px)
                    VStack(alignment: .leading, spacing: AppConstants.spacingXS) {
                        HStack(spacing: AppConstants.spacingSM) {
                            Circle()
                                .fill(AppColors.text)
                                .frame(width: 16, height: 16)
                            
                            Text("WHAT TO EXPECT")
                                .font(.system(size: AppConstants.fontSizeSectionHeader, weight: .bold))
                                .tracking(AppConstants.trackingSectionHeader)
                                .foregroundColor(AppColors.textSecondary)
                        }
                        
                        Text(investment.whatToExpect)
                            .font(.system(size: AppConstants.fontSizeBody, weight: .regular))
                            .foregroundColor(AppColors.textSecondary)
                            .lineSpacing(6)
                    }
                    .padding(AppConstants.spacingMD)
                    .background(AppColors.darkGray)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(AppColors.border, lineWidth: 1)
                    )
                    .cornerRadius(8)
                    
                    // Good Reasons (padding: 16px, background: green 8% opacity, border: green 20% opacity, bullet spacing: 10px)
                    VStack(alignment: .leading, spacing: AppConstants.spacingSM) {
                        Text("✓ GOOD REASONS TO CONSIDER")
                            .font(.system(size: AppConstants.fontSizeSectionHeader, weight: .bold))
                            .tracking(AppConstants.trackingSectionHeader)
                            .foregroundColor(AppColors.green)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(investment.goodReasons, id: \.self) { reason in
                                HStack(alignment: .top, spacing: 10) {
                                    Text("•")
                                        .font(.system(size: 16))
                                        .foregroundColor(AppColors.green)
                                        .padding(.top, 2)
                                    Text(reason)
                                        .font(.system(size: AppConstants.fontSizeBody, weight: .regular))
                                        .foregroundColor(AppColors.text)
                                        .lineSpacing(6)
                                }
                            }
                        }
                    }
                    .padding(AppConstants.spacingMD)
                    .background(AppColors.green.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(AppColors.green.opacity(0.2), lineWidth: 1)
                    )
                    .cornerRadius(8)
                    
                    // Concerns (padding: 16px, background: red 8% opacity, border: red 20% opacity, bullet spacing: 10px)
                    VStack(alignment: .leading, spacing: AppConstants.spacingSM) {
                        Text("⚠ THINGS TO WATCH OUT FOR")
                            .font(.system(size: AppConstants.fontSizeSectionHeader, weight: .bold))
                            .tracking(AppConstants.trackingSectionHeader)
                            .foregroundColor(AppColors.red)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(investment.concerns, id: \.self) { concern in
                                HStack(alignment: .top, spacing: 10) {
                                    Text("•")
                                        .font(.system(size: 16))
                                        .foregroundColor(AppColors.red)
                                        .padding(.top, 2)
                                    Text(concern)
                                        .font(.system(size: AppConstants.fontSizeBody, weight: .regular))
                                        .foregroundColor(AppColors.text)
                                        .lineSpacing(6)
                                }
                            }
                        }
                    }
                    .padding(AppConstants.spacingMD)
                    .background(AppColors.red.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(AppColors.red.opacity(0.2), lineWidth: 1)
                    )
                    .cornerRadius(8)
                    
                    // Timeline & Risk Level Pills (padding: 12px, corner radius: 8px, border: 1px #333333, gap: 12px)
                    HStack(spacing: AppConstants.spacingSM) {
                        VStack(alignment: .leading, spacing: AppConstants.spacingXS) {
                            Text("TIME HORIZON")
                                .font(.system(size: AppConstants.fontSizeSectionHeader, weight: .bold))
                                .tracking(AppConstants.trackingSectionHeader)
                                .foregroundColor(AppColors.textSecondary)
                            Text(investment.timeline)
                                .font(.system(size: AppConstants.fontSizeBody, weight: .regular))
                                .foregroundColor(AppColors.textSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(AppConstants.spacingSM)
                        .background(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(AppColors.border, lineWidth: 1)
                        )
                        .cornerRadius(8)
                        
                        VStack(alignment: .leading, spacing: AppConstants.spacingXS) {
                            Text("RISK LEVEL")
                                .font(.system(size: AppConstants.fontSizeSectionHeader, weight: .bold))
                                .tracking(AppConstants.trackingSectionHeader)
                                .foregroundColor(AppColors.textSecondary)
                            Text(investment.riskLevel)
                                .font(.system(size: AppConstants.fontSizeBody, weight: .regular))
                                .foregroundColor(AppColors.text)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(AppConstants.spacingSM)
                        .background(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(AppColors.text, lineWidth: 1)
                        )
                        .cornerRadius(8)
                    }
                    
                    // Beginner Tip (padding: 16px, corner radius: 8px, border: 1px #333333)
                    if !investment.beginnerTip.isEmpty {
                        VStack(alignment: .leading, spacing: AppConstants.spacingXS) {
                            HStack(spacing: AppConstants.spacingSM) {
                                Image(systemName: "lightbulb.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(AppColors.text)
                                
                                Text("BEGINNER TIP")
                                    .font(.system(size: AppConstants.fontSizeSectionHeader, weight: .bold))
                                    .tracking(AppConstants.trackingSectionHeader)
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            
                            Text(investment.beginnerTip)
                                .font(.system(size: AppConstants.fontSizeBody, weight: .regular))
                                .foregroundColor(AppColors.textSecondary)
                                .lineSpacing(6)
                        }
                        .padding(AppConstants.spacingMD)
                        .background(AppColors.darkGray)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(AppColors.border, lineWidth: 1)
                        )
                        .cornerRadius(8)
                    }
                    
                    // Sources (padding: 12px, corner radius: 6px, border: 1px #333333, arrow: 12px)
                    if !investment.sources.isEmpty {
                        VStack(alignment: .leading, spacing: AppConstants.spacingSM) {
                            Text("SOURCES")
                                .font(.system(size: AppConstants.fontSizeSectionHeader, weight: .bold))
                                .tracking(AppConstants.trackingSectionHeader)
                                .foregroundColor(AppColors.textSecondary)
                            
                            VStack(spacing: AppConstants.spacingXS) {
                                ForEach(investment.sources) { source in
                                    if let url = URL(string: source.url) {
                                        Link(destination: url) {
                                            HStack {
                                                Text(source.name)
                                                    .font(.system(size: AppConstants.fontSizeBody, weight: .regular))
                                                    .foregroundColor(AppColors.textSecondary)
                                                Spacer()
                                                Image(systemName: "arrow.up.right")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(AppColors.textSecondary)
                                            }
                                            .padding(AppConstants.spacingSM)
                                            .background(Color.clear)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 6)
                                                    .stroke(AppColors.border, lineWidth: 1)
                                            )
                                            .cornerRadius(6)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // Get Started Section (padding: 14px, corner radius: 8px, border: 1px #333333, arrow: 14px)
                    if !investment.getStarted.isEmpty {
                        VStack(alignment: .leading, spacing: AppConstants.spacingSM) {
                            HStack(spacing: 6) {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(AppColors.text)
                                
                                Text("GET STARTED")
                                    .font(.system(size: AppConstants.fontSizeSectionHeader, weight: .bold))
                                    .tracking(AppConstants.trackingSectionHeader)
                                    .foregroundColor(AppColors.text)
                            }
                            
                            VStack(spacing: AppConstants.spacingXS) {
                                ForEach(investment.getStarted) { resource in
                                    if let url = URL(string: resource.url) {
                                        Link(destination: url) {
                                            HStack {
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text(resource.name)
                                                        .font(.system(size: AppConstants.fontSizeBody, weight: .regular))
                                                        .foregroundColor(AppColors.text)
                                                    if !resource.description.isEmpty {
                                                        Text(resource.description)
                                                            .font(.system(size: 13, weight: .regular))
                                                            .foregroundColor(AppColors.textSecondary)
                                                    }
                                                }
                                                Spacer()
                                                Image(systemName: "arrow.up.right")
                                                    .font(.system(size: 14))
                                                    .foregroundColor(AppColors.text)
                                            }
                                            .padding(14)
                                            .background(Color.clear)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(AppColors.border, lineWidth: 1)
                                            )
                                            .cornerRadius(8)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(AppConstants.spacingLG) // 24px all sides (matching React mockup)
            }
        }
        .background(AppColors.cardBackground)
        .cornerRadius(AppConstants.cardCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.cardCornerRadius)
                .stroke(AppColors.border, lineWidth: 1)
        )
        .accessibilityLabel(accessibilityCardLabel)
        .accessibilityHint("Swipe left to pass, swipe right to save")
        .onAppear {
            viewStartTime = Date()
            AnalyticsHelper.trackCardViewed(
                type: investment.type.rawValue,
                title: investment.type == .stock ? (investment.ticker ?? investment.title) : investment.title
            )
        }
        .onDisappear {
            let timeSpent = Date().timeIntervalSince(viewStartTime)
            if timeSpent >= 3 {
                FirebaseManager.shared.logEvent("card_engaged", parameters: [
                    "type": investment.type.rawValue,
                    "time_spent": Int(timeSpent)
                ])
            }
        }
    }
    
    private var accessibilityCardLabel: String {
        if investment.type == .stock {
            return "Stock recommendation: \(investment.ticker ?? ""). \(investment.title). Current price \(investment.price ?? ""). \(investment.tagline)"
        } else {
            return "Business idea: \(investment.title). Investment range \(investment.investment ?? ""). \(investment.tagline)"
        }
    }
}

// Noise texture view
struct NoiseTextureView: View {
    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                // Create a simple noise pattern using random dots
                for _ in 0..<Int(size.width * size.height / 100) {
                    let x = Double.random(in: 0..<size.width)
                    let y = Double.random(in: 0..<size.height)
                    let opacity = Double.random(in: 0.02...0.05)
                    
                    context.fill(
                        Path(ellipseIn: CGRect(x: x, y: y, width: 1, height: 1)),
                        with: .color(.white.opacity(opacity))
                    )
                }
            }
        }
    }
}
