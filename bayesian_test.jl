module BayesianABTest  # このモジュールは、ベイズ的なA/Bテストを実行するためのコードをまとめたものです。

using Turing           # Turingパッケージを使用して、ベイズモデルの構築とサンプリングを実行
using Distributions     # 確率分布(Beta, Binomialなど)を定義するためのパッケージ
using Random            # ランダムサンプリングのためのユーティリティ
using MCMCChains        # MCMCサンプリングの結果を解析するためのパッケージ
using DataFrames        # データフレーム形式でデータを操作するためのパッケージ

struct ABTestData
    nA::Int         # グループAの表示回数
    successA::Int   # グループAの成功回数
    nB::Int         # グループBの表示回数
    successB::Int   # グループBの成功回数
end

"""
    bayesian_test(data::ABTestData; nsamples::Int=2000, nburn::Int=500) :: Dict{Symbol, Any}

    A/Bテストデータをベイズモデルで解析し、事後分布をサンプリングします。
    - 引数: nsamples: サンプリング数, nburn: 焼きなまし期間
    - 戻り値: ベイズ解析の結果(事後サンプル、確率など)
"""
function bayesian_test(data::ABTestData; nsamples::Int=2000, nburn::Int=500) :: Dict{Symbol, Any}
    # ベイズモデルの定義
    @model function ab_model(nA::Int, successA::Int, nB::Int, successB::Int)
        pA ~ Beta(1,1)  # グループAの成功率の事前分布
        pB ~ Beta(1,1)  # グループBの成功率の事前分布
        successA ~ Binomial(nA, pA)  # グループAの観測データ
        successB ~ Binomial(nB, pB)  # グループBの観測データ
    end

    # モデルをデータで初期化
    model = ab_model(data.nA, data.successA, data.nB, data.successB)

    # サンプリング (NUTSアルゴリズムを使用して事後分布をサンプリング)
    chain = sample(model, NUTS(), nsamples + nburn)

    # 焼きなまし期間を除外
    posterior = chain[nburn+1:end]

    # 事後サンプルを DataFrame に変換
    df = DataFrame(posterior)

    # 事後サンプルから pA と pB を取得
    pA_samples = df[!, :pA]  # pA のサンプル
    pB_samples = df[!, :pB]  # pB のサンプル

    # pA > pB となる確率を計算
    p_greater = mean(pA_samples .> pB_samples)

    # 結果を辞書形式で返す
    return Dict(
        :posterior_samples => df,           # 事後サンプルの DataFrame
        :p_greater => p_greater,            # pA > pB の確率
        :mean_pA => mean(pA_samples),       # pA の平均値
        :mean_pB => mean(pB_samples),       # pB の平均値
    )
end

end # module
