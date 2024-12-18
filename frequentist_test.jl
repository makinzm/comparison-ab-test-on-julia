module FrequentistABTest
using Statistics  # 平均や分散の計算で使用
using Distributions  # 正規分布の累積分布関数を使用

# A/Bテスト用のデータ型を定義
struct ABTestData
    nA::Int         # グループAの表示回数
    successA::Int   # グループAの成功回数
    nB::Int         # グループBの表示回数
    successB::Int   # グループBの成功回数
end

"""
    frequentist_test(data::ABTestData, sided::Symbol) :: Tuple{Float64, Float64}

    A/Bテストデータを基に、カイ二乗近似を用いたZ検定を実行します。
    - 戻り値: (検定統計量, p値)
"""
function frequentist_test(data::ABTestData, sided::Symbol) :: Tuple{Float64, Float64}
    # グループAとBの成功率
    pA = data.successA / data.nA
    pB = data.successB / data.nB

    # グループ全体の成功率
    p_pool = (data.successA + data.successB) / (data.nA + data.nB)

    # 検定統計量 (Z値) を計算
    z = (pA - pB) / sqrt(p_pool * (1 - p_pool) * (1/data.nA + 1/data.nB))

    # p値を計算
    if sided == :two_sided
      p_value = 2 * (1 - cdf(Normal(0, 1), abs(z)))
    elseif sided == :one && pA > pB
      p_value = 1 - cdf(Normal(0, 1), z)
    elseif sided == :one && pA < pB
      p_value = cdf(Normal(0, 1), z)
    else
      throw(ArgumentError("sided must be :two_sided or :one"))
    end
    return (z, p_value)
end

end # module

