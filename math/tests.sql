-- sample calls; expected values computed with Python scipy in the comments
SELECT math.fnCumulativeProbability(9.33)                   -- 1
SELECT math.fnCumulativeProbability(1.5)                    -- 0.9331927987
SELECT math.fnCumulativeProbability(-8)                     -- 0
SELECT math.fnInverseCumulativeProbability(0.99)            -- 2.326347874
SELECT math.fnErfInv(0.5)                                   -- 0.4769362762044699
SELECT math.fnLogGamma(5)                                   -- 3.1780538303479458 (log 24)
SELECT math.fnRegularizedGammaP(2, 1, 1e-15, 10000)         -- 0.2642411176571153
SELECT math.fnRegularizedGammaQ(2, 5, 1e-15, 10000)         -- 0.04042768199451279
SELECT math.fnErfc(1)                                       -- 0.15729920705028516
