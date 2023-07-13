import boa
import pytest


@pytest.fixture(scope="module")
def gauge_interface():
    return boa.load_partial("contracts/main/LiquidityGauge.vy")


@pytest.fixture(scope="module")
def gauge_implementation(deployer, gauge_interface):
    with boa.env.prank(deployer):
        return gauge_interface.deploy_as_blueprint()


@pytest.fixture(scope="module")
def amm_interface():
    return boa.load_partial("contracts/main/CurveStableSwapNG.vy")


@pytest.fixture(scope="module")
def amm_implementation(deployer, amm_interface):
    with boa.env.prank(deployer):
        return amm_interface.deploy_as_blueprint()


@pytest.fixture(scope="module")
def amm_interface_meta():
    return boa.load_partial("contracts/main/CurveStableSwapMetaNG.vy")


@pytest.fixture(scope="module")
def amm_implementation_meta(deployer, amm_interface_meta):
    with boa.env.prank(deployer):
        return amm_interface_meta.deploy_as_blueprint()


@pytest.fixture(scope="module")
def views_implementation(deployer):
    with boa.env.prank(deployer):
        return boa.load("contracts/main/CurveStableSwapNGViews.vy")


@pytest.fixture(scope="module")
def factory(
    deployer,
    fee_receiver,
    owner,
    weth,
):
    with boa.env.prank(deployer):
        _factory = boa.load(
            "contracts/main/CurveStableSwapFactoryNG.vy",
            fee_receiver,
            owner,
            weth,
        )
    return _factory


# <---------------------   Functions   --------------------->
@pytest.fixture(scope="module")
def set_pool_implementations(owner, factory, amm_implementation):
    with boa.env.prank(owner):
        factory.set_pool_implementations(0, amm_implementation.address)


@pytest.fixture(scope="module")
def set_metapool_implementations(owner, factory, amm_implementation_meta):
    with boa.env.prank(owner):
        factory.set_pool_implementations(0, amm_implementation_meta.address)


@pytest.fixture(scope="module")
def add_base_pool(
    owner,
    factory,
    base_pool,
    base_pool_lp_token,
    base_pool_tokens,
):
    with boa.env.prank(owner):
        factory.add_base_pool(
            base_pool.address,
            base_pool_lp_token.address,
            [t.address for t in base_pool_tokens],
            [0] * len(base_pool_tokens),
            len(base_pool_tokens),
        )


@pytest.fixture(scope="module")
def set_gauge_implementation(owner, factory, gauge_implementation):
    with boa.env.prank(owner):
        factory.set_gauge_implementation(gauge_implementation.address)


@pytest.fixture(scope="module")
def set_views_implementation(owner, factory, views_implementation):
    with boa.env.prank(owner):
        factory.set_views_implementation(views_implementation.address)


@pytest.fixture(scope="module")
def gauge(owner, factory, swap, gauge_interface, set_gauge_implementation):
    with boa.env.prank(owner):
        gauge_address = factory.deploy_gauge(swap.address)
    return gauge_interface.at(gauge_address)
