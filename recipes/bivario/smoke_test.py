if __name__ == "__main__":
    from bivario import get_bivariate_cmap
    from bivario.example_data import nyc_bike_trips

    dataset = nyc_bike_trips()

    bv_cmap = get_bivariate_cmap()

    cmap = bv_cmap(values_a=dataset["morning_starts"], values_b=dataset["morning_ends"])

    if cmap.shape == (1569, 3):
        print("Smoke test succeeded")
    else:
        raise RuntimeError(f"Returned data has unexpected shape: {cmap.shape}")