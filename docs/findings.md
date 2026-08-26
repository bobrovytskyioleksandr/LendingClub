# Analysis notes

Here I would try to outline the most interesting findings from my work on this dataset.

## Overview

- 9 SQL scripts with different categories of analytical queries separated by topic to the best of my abilities.
- Most are concerned with the risk, expressed through default rate, and how it correlates with certain characteristics of the loan or the borrower.

## Findings

Most of the main risk indicators, such as grade and FICO score, were directly correlated with default rate and subsequently with interest rate. Nevertheless, I found an interesting effect that occurs when a specific characteristic of a borrower is not readily available. For example, the income verification status showed a negative correlation to the default rate, so borrowers with non-verified income were by far the most reliable(~15% default rate vs ~21-24 for verified ones).

Maybe not as relevant but still really interesting was exploring default rates by purpose. The lowest one of ~12.4% belonged to the "wedding" category, which was not what I had expected, but I can understand why. On the other hand, "small business" was the worst category with the highest default rate of ~29.9%, which is also easily explainable as starting a new business is always a risky venture.

Another unexpected finding from this dataset was how high, in fact, the default rates are for those loans. Even only considering loans that had enough time to fully expire, the default rate is really high; even for grade A it is 5.5%, which is not a lot on its own if not for the fact that this is the best grade. For everything below grade A, the default rate quickly goes upwards, with grade C being >18% and grade G(the worst one) sitting at ~37.5%, so more than a third of all loans have defaulted.

By far the most surprising findings came from the result of my analysis on the average cash return for the loans in every grade. Especially shocking were the 3 lowest grades (E, F, G) where the average amount recovered was lower than the amount funded, showing a clear loss on investment even before accounting for the cost of capital. The actual non-adjusted return for those grades is ~98.7%, 96.3%, and ~90.7%, respectively.

On top of that, the situation is barely better for higher-grade loans, with A and B being most profitable, with approximately equal 105.2% recovered, which is still pretty bad considering that the loans have a fixed lifespan of 3 to 5 years, resulting in the average returns not even covering inflation. The most obvious explanation for that might be that the interest rate does not scale proportionally to the default rate. A: G default rate is ~1:7 and A: G interest rate is 1:4. So the lenders do not get appropriate compensation for the risk they take.

Although the returns for retail investors might seem underwhelming, it does not mean that the Lending Club itself loses money. Their main business model is to connect people wanting to borrow with those willing to lend. They take their fee before the underlying loan can ever default.
