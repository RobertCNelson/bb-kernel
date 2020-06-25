#!/bin/sh -e

DIR=$PWD

config_enable () {
	ret=$(./scripts/config --state ${config})
	if [ ! "x${ret}" = "xy" ] ; then
		echo "Setting: ${config}=y"
		./scripts/config --enable ${config}
	fi
}

config_disable () {
	ret=$(./scripts/config --state ${config})
	if [ ! "x${ret}" = "xn" ] ; then
		echo "Setting: ${config}=n"
		./scripts/config --disable ${config}
	fi
}

config_enable_special () {
	test_module=$(cat .config | grep ${config} || true)
	if [ "x${test_module}" = "x# ${config} is not set" ] ; then
		echo "Setting: ${config}=y"
		sed -i -e 's:# '$config' is not set:'$config'=y:g' .config
	fi
	if [ "x${test_module}" = "x${config}=m" ] ; then
		echo "Setting: ${config}=y"
		sed -i -e 's:'$config'=m:'$config'=y:g' .config
	fi
}

config_module_special () {
	test_module=$(cat .config | grep ${config} || true)
	if [ "x${test_module}" = "x# ${config} is not set" ] ; then
		echo "Setting: ${config}=m"
		sed -i -e 's:# '$config' is not set:'$config'=m:g' .config
	else
		echo "$config=m" >> .config
	fi
}

config_module () {
	ret=$(./scripts/config --state ${config})
	if [ ! "x${ret}" = "xm" ] ; then
		echo "Setting: ${config}=m"
		./scripts/config --module ${config}
	fi
}

config_string () {
	ret=$(./scripts/config --state ${config})
	if [ ! "x${ret}" = "x${option}" ] ; then
		echo "Setting: ${config}=\"${option}\""
		./scripts/config --set-str ${config} "${option}"
	fi
}

config_value () {
	ret=$(./scripts/config --state ${config})
	if [ ! "x${ret}" = "x${option}" ] ; then
		echo "Setting: ${config}=${option}"
		./scripts/config --set-val ${config} ${option}
	fi
}

cd ${DIR}/KERNEL/

#Nuke DSA SubSystem: 2020.02.20
config="CONFIG_HAVE_NET_DSA" ; config_disable
config="CONFIG_NET_DSA" ; config_disable

config="CONFIG_MCP320X" ; config_module
config="CONFIG_BMI160_I2C" ; config_module
config="CONFIG_INV_MPU6050_I2C" ; config_module
config="CONFIG_INV_MPU6050_SPI" ; config_module
config="CONFIG_IIO_ST_LSM6DSX_I2C" ; config_module
config="CONFIG_IIO_ST_ACCEL_I2C_3AXIS" ; config_module
config="CONFIG_BMA400_I2C" ; config_module
config="CONFIG_AD5593R" ; config_module
config="CONFIG_MCP320X" ; config_module
config="CONFIG_MCP3422" ; config_module
config="CONFIG_AD7476" ; config_module
config="CONFIG_AD7124" ; config_module
config="CONFIG_TI_ADS1015" ; config_module
config="CONFIG_MCP320X" ; config_module
config="CONFIG_CCS811" ; config_module
config="CONFIG_SENSORS_MCP3021" ; config_module
config="CONFIG_SENSORS_MCP3021" ; config_module
config="CONFIG_ICP10100" ; config_module
config="CONFIG_MPL3115" ; config_module
config="CONFIG_OPT3001" ; config_module
config="CONFIG_BH1750" ; config_module
config="CONFIG_VEML6030" ; config_module
config="CONFIG_MCP320X" ; config_module
config="CONFIG_ISL29125" ; config_module
config="CONFIG_TCS3472" ; config_module
config="CONFIG_IIO_ST_MAGN_I2C_3AXIS" ; config_module
config="CONFIG_MCP320X" ; config_module
config="CONFIG_MCP4725" ; config_module
config="CONFIG_MCP4922" ; config_module
config="CONFIG_MCP4131" ; config_module
config="CONFIG_AD5446" ; config_module
config="CONFIG_EEPROM_AT24" ; config_module
config="CONFIG_EEPROM_AT24" ; config_module
config="CONFIG_BME680_I2C" ; config_module
config="CONFIG_ENC28J60" ; config_module
config="CONFIG_WIZNET_W5100_SPI" ; config_module
config="CONFIG_BMC150_MAGN_I2C" ; config_module
config="CONFIG_MCP320X" ; config_module
config="CONFIG_FXAS21002C_I2C" ; config_module
config="CONFIG_SENSORS_MCP3021" ; config_module
config="CONFIG_MCP320X" ; config_module
config="CONFIG_SENSORS_MCP3021" ; config_module
config="CONFIG_HDC100X" ; config_module
config="CONFIG_AFE4404" ; config_module
config="CONFIG_MAX30102" ; config_module
config="CONFIG_AFE4404" ; config_module
config="CONFIG_APDS9960" ; config_module
config="CONFIG_TMP007" ; config_module
config="CONFIG_RFD77402" ; config_module
config="CONFIG_VL6180" ; config_module
config="CONFIG_IIO_ST_LSM6DSX_I2C" ; config_module
config="CONFIG_SENSORS_MCP3021" ; config_module
config="CONFIG_MCP320X" ; config_module
config="CONFIG_MMC_SPI" ; config_module
config="CONFIG_INV_MPU6050_I2C" ; config_module
config="CONFIG_MCP320X" ; config_module
config="CONFIG_FB_TFT_SSD1306" ; config_module
config="CONFIG_FB_TFT_SSD1351" ; config_module
config="CONFIG_FB_TFT_SSD1306" ; config_module
config="CONFIG_MCP320X" ; config_module
config="CONFIG_IIO_ST_PRESS_I2C" ; config_module
config="CONFIG_DPS310" ; config_module
config="CONFIG_MS5637" ; config_module
config="CONFIG_IIO_ST_PRESS" ; config_module
config="CONFIG_SI1145" ; config_module
config="CONFIG_VCNL4035" ; config_module
config="CONFIG_VCNL4000" ; config_module
config="CONFIG_VCNL4000" ; config_module
config="CONFIG_MCP320X" ; config_module
config="CONFIG_MCP320X" ; config_module
config="CONFIG_RTC_DRV_DS1307" ; config_module
config="CONFIG_SENSORS_SHT3x" ; config_module
config="CONFIG_MAX30102" ; config_module
config="CONFIG_HDC100X" ; config_module
config="CONFIG_HDC100X" ; config_module
config="CONFIG_SI7020" ; config_module
config="CONFIG_SENSORS_SHTC1" ; config_module
config="CONFIG_SENSORS_JC42" ; config_module
config="CONFIG_SENSORS_JC42" ; config_module
config="CONFIG_SENSORS_LM90" ; config_module
config="CONFIG_SENSORS_TMP102" ; config_module
config="CONFIG_SENSORS_LM75" ; config_module
config="CONFIG_SENSORS_LM75" ; config_module
config="CONFIG_MAXIM_THERMOCOUPLE" ; config_module
config="CONFIG_AS3935" ; config_module
config="CONFIG_VEML6070" ; config_module
config="CONFIG_SENSORS_MCP3021" ; config_module
config="CONFIG_MCP320X" ; config_module
config="CONFIG_BMP280_I2C" ; config_module

cd ${DIR}/
