"""
Automatic distribution-cropping method for metric threshold derivation.
Based on Fontana et al. (2015), "Automatic Metric Thresholds Derivation
for Code Smell Detection", WETSoM 2015, Section II.B.3.
"""

import argparse

import numpy as np
import pandas as pd


def find_cut_point(values, n_points=100):
    values = np.asarray(values, dtype=float)
    values = values[~np.isnan(values)]

    quantile_positions = np.arange(1, n_points + 1) / n_points
    a = np.array(
        [np.percentile(values, q * 100, method="inverted_cdf") for q in quantile_positions],
        dtype=float,
    )

    unique_vals, counts = np.unique(a, return_counts=True)
    f_mid = np.median(counts)

    order = np.argsort(unique_vals)
    uv_sorted = unique_vals[order]
    freq_sorted = counts[order]

    v_mid = uv_sorted[-1]
    for i in range(len(uv_sorted)):
        if np.all(freq_sorted[i:] <= f_mid):
            v_mid = uv_sorted[i]
            break

    below = quantile_positions[a < v_mid]
    cut_percentile = below.max() * 100 if below.size else 0.0

    return cut_percentile, v_mid


def final_threshold(values, percentile=75, n_points=100):
    values = np.asarray(values, dtype=float)
    values = values[~np.isnan(values)]

    cut_pct, v_mid = find_cut_point(values, n_points=n_points)
    cropped = values[values >= v_mid]
    threshold = np.percentile(cropped, percentile, method="inverted_cdf")

    return {
        "cut_percentile": cut_pct,
        "v_mid": v_mid,
        "n_kept": cropped.size,
        "threshold": threshold,
    }


def extract_thresholds(csv_path, metrics, percentile=75):
    df = pd.read_csv(csv_path)

    print(f"{'Metric':<10} {'Cut %':>8} {'v_mid':>8} {'Kept':>8} {'Threshold':>10}")
    for metric in metrics:
        result = final_threshold(df[metric].values, percentile=percentile)
        print(
            f"{metric:<10} {result['cut_percentile']:8.1f} "
            f"{result['v_mid']:8.2f} {result['n_kept']:8d} "
            f"{result['threshold']:10.2f}"
        )


def main():
    parser = argparse.ArgumentParser(description="Derive metric thresholds via distribution cropping.")
    parser.add_argument("--input", required=True, help="Path to the CSV file with metric values.")
    parser.add_argument("--metrics", nargs="+", required=True, help="Column names to process (e.g. LOC CC).")
    parser.add_argument("--percentile", type=float, default=75, help="Percentile applied after cropping.")
    args = parser.parse_args()

    extract_thresholds(args.input, args.metrics, args.percentile)


if __name__ == "__main__":
    main()
