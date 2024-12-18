include("frequentist_test.jl")  # 頻度論的アプローチのモジュールを読み込む
include("bayesian_test.jl")    # ベイズ的アプローチのモジュールを読み込む

using .FrequentistABTest       # 頻度論的モジュールのエイリアス
using .BayesianABTest          # ベイズ的モジュールのエイリアス
using CSV                      # CSVファイルを扱うためのパッケージ
using DataFrames               # データフレーム形式でデータを操作するためのパッケージ
using Random                   # 乱数生成のためのパッケージ

# 出力ディレクトリを作成
results_dir = "results"
if !isdir(results_dir)
    mkpath(results_dir)
end

# ログファイルを準備
log_file = joinpath(results_dir, "output_log.txt")
open(log_file, "w") do io  # ログファイルを開く
    # printlnの内容をファイルと画面に同時出力する関数
    function log_and_print(msg)
        println(msg)         # 標準出力に出力
        println(io, msg)     # ログファイルに出力
    end

    # 乱数シードを設定
    Random.seed!(1234)

    # テストデータ
    data = FrequentistABTest.ABTestData(1000, 120, 1000, 110)

    # 頻度論的アプローチ
    stat, pval = FrequentistABTest.frequentist_test(data, :one)
    log_and_print("Frequentist: statistic = $stat, p-value = $pval")

    # ベイズ的アプローチ
    bayesian_data = BayesianABTest.ABTestData(data.nA, data.successA, data.nB, data.successB)
    result = BayesianABTest.bayesian_test(bayesian_data; nsamples=2000, nburn=500)
    log_and_print("Bayesian: p(A>B) = $(result[:p_greater])")
    log_and_print("mean pA = $(result[:mean_pA]), mean pB = $(result[:mean_pB])")

    # ベイズ的事後サンプルをCSVに保存
    posterior_df = DataFrame(result[:posterior_samples])
    csv_file = joinpath(results_dir, "bayesian_results.csv")
    CSV.write(csv_file, posterior_df)
    log_and_print("Results saved to $csv_file")
end  # ログファイルを閉じる

