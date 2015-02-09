require './jalaali.rb'

describe 'toJalaali' do
  it 'converts garigorian date to jalaali date' do
    bits = toJalaali 1981, 9, 10
    expect(bits[:jy]).to eq 1360
    expect(bits[:jm]).to eq 6
    expect(bits[:jd]).to eq 19
  end

  it 'converts today correctly' do
    days = g2d 2015, 2, 9
    expect(days).to eq 2457063

    bits = d2g days
    expect(bits[:gy]).to eq 2015
    expect(bits[:gm]).to eq 2
    expect(bits[:gd]).to eq 9

    bits = toJalaali 2015, 2, 9
    expect(bits[:jy]).to eq 1393
    expect(bits[:jm]).to eq 11
    expect(bits[:jd]).to eq 20
  end
end

describe 'div' do
  it 'divides negative' do
    expect(div(-6,6)).to eq -1
    expect(mod(12,12)).to eq 0
  end
end
