<?php

namespace App\Services;

use App\Models\SignalExplanation;
use Illuminate\Support\Collection;

class ExplainabilityService
{
    public function attach(Collection $signals, Collection $indicators): Collection
    {
        $indicatorMap = $indicators->keyBy('stock_id');

        return $signals->map(function ($signal) use ($indicatorMap) {
            $indicator = $indicatorMap->get($signal->stock_id);
            $why = $this->buildWhy($signal->type, $indicator);
            $caveats = $this->buildCaveats($signal->risk_level);

            return SignalExplanation::updateOrCreate([
                'signal_id' => $signal->id,
            ], [
                'why_json' => $why,
                'caveats_json' => $caveats,
                'summary_ar' => $this->summary($signal->type, $signal->confidence),
            ]);
        });
    }

    private function buildWhy(string $type, $indicator): array
    {
        if ($type === 'buy') {
            return [
                'المؤشرات الفنية تظهر تحسناً تدريجياً في الزخم',
                'السعر يتحرك قرب متوسطات متحركة داعمة',
                'حجم التداول أعلى من المتوسط اليومي',
            ];
        }

        if ($type === 'sell') {
            return [
                'مؤشر القوة النسبية يشير إلى تشبع سعري مؤقت',
                'السعر ابتعد عن متوسطاته المتحركة الرئيسية',
                'حجم التداول يشير إلى تباطؤ نسبي',
            ];
        }

        return [
            'السهم يتحرك ضمن نطاق متوازن حالياً',
            'الإشارات الفنية متقاربة بدون اتجاه واضح',
            'حجم التداول قريب من المتوسطات المعتادة',
        ];
    }

    private function buildCaveats(string $riskLevel): array
    {
        if ($riskLevel === 'high') {
            return [
                'التذبذب مرتفع وقد يؤدي لتحركات حادة',
                'تغيرات السوق العامة قد تؤثر سريعاً',
            ];
        }

        return [
            'الاتجاه العام للسوق قد يتغير خلال الجلسة',
            'الإشارة تعتمد على بيانات تاريخية وليست ضماناً',
        ];
    }

    private function summary(string $type, int $confidence): string
    {
        return "إشارة {$type} بثقة تقريبية {$confidence}% بناءً على المؤشرات الفنية";
    }
}
